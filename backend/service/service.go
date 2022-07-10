package service

import (
	"context"
	"fmt"
	"github.com/custom-app/minter-guru/backend/contracts/migu_token"
	"github.com/dgrijalva/jwt-go"
	"github.com/ethereum/go-ethereum/accounts/abi/bind"
	"github.com/ethereum/go-ethereum/common"
	"github.com/go-kit/kit/endpoint"
	httptransport "github.com/go-kit/kit/transport/http"
	"github.com/gorilla/mux"
	"github.com/jackc/pgx/v4"
	"github.com/jackc/pgx/v4/pgxpool"
	"log"
	"math/big"
	"net/http"
	"strings"
	"time"
)

var nowFunc = time.Now

func Now() time.Time {
	return nowFunc()
}

type MinterGuruService interface {
	GetAuthMessage(context.Context, string) (string, *ErrorResponse)
	Auth(context.Context, string, string) (*AuthResponse, *ErrorResponse)
	Faucet(context.Context, int64) (*Transaction, *ErrorResponse)
	ApplyForTwitterReward(context.Context, int64) (*TwitterReward, *ErrorResponse)
	GetTwitterRewards(context.Context, int64) ([]*TwitterReward, *ErrorResponse)
}

type EthProvider interface {
	bind.ContractBackend
	BalanceAt(ctx context.Context, contract common.Address, blockNumber *big.Int) (*big.Int, error)
}

type MinterGuruServiceImpl struct {
	cfg           *Config
	server        *http.Server
	pool          *pgxpool.Pool
	closeCh       chan struct{}
	ethClient     EthProvider
	tokenInstance *migu_token.MinterGuruToken
}

func NewMinterGuruServiceImpl(cfg *Config, ethClient EthProvider) (*MinterGuruServiceImpl, error) {
	tokenInstance, err := migu_token.NewMinterGuruToken(common.HexToAddress(cfg.getMinterGuruTokenAddress()), ethClient)
	if err != nil {
		return nil, err
	}
	return &MinterGuruServiceImpl{
		cfg:           cfg,
		ethClient:     ethClient,
		tokenInstance: tokenInstance,
	}, nil
}

func (s *MinterGuruServiceImpl) Start(ctx context.Context) error {
	s.closeCh = make(chan struct{})
	var err error
	s.pool, err = pgxpool.Connect(ctx, s.cfg.getPgSource())
	if err != nil {
		return err
	}
	authMessageHandler := httptransport.NewServer(
		makeAuthMessageEndpoint(s),
		decodeAuthMessageRequest,
		encodeResponse,
	)
	authHandler := httptransport.NewServer(
		makeAuthEndpoint(s),
		decodeAuthRequest,
		encodeResponse,
	)
	getTwitterRewardsHandler := httptransport.NewServer(
		s.authMiddleware(makeGetTwitterRewardsEndpoint(s)),
		decodeEmptyRequest,
		encodeResponse,
	)
	applyForTwitterRewardHandler := httptransport.NewServer(
		s.authMiddleware(makeApplyForTwitterRewardsEndpoint(s)),
		decodeEmptyRequest,
		encodeResponse,
	)
	faucetHandler := httptransport.NewServer(
		s.authMiddleware(makeFaucetEndpoint(s)),
		decodeEmptyRequest,
		encodeResponse,
	)

	router := mux.NewRouter()

	authRouter := router.PathPrefix("/auth").Methods(http.MethodPost).Subrouter()
	authRouter.Handle("/message", authMessageHandler)
	authRouter.Handle("", authHandler)

	twitterRouter := router.PathPrefix("/twitter").Methods(http.MethodPost).Subrouter()
	twitterRouter.Handle("/get_records", getTwitterRewardsHandler)
	twitterRouter.Handle("", applyForTwitterRewardHandler)

	router.Handle("/faucet", faucetHandler)

	s.server = &http.Server{
		Handler: router,
		Addr:    fmt.Sprintf(":%d", s.cfg.getPort()),
	}
	go s.doPeriodJobs()
	go func() {
		if err := s.server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Panicln("listen failed", err)
		}
	}()
	return nil
}

func (s *MinterGuruServiceImpl) authMiddleware(next endpoint.Endpoint) endpoint.Endpoint {
	return func(ctx context.Context, request interface{}) (interface{}, error) {
		authHeaderValue, ok := ctx.Value(httptransport.ContextKeyRequestAuthorization).(string)
		if !ok {
			return WithDetail(ParseFailed, "missing auth header"), nil
		}
		if !strings.HasPrefix(authHeaderValue, "Bearer ") {
			return WithDetail(ParseFailed, "auth header wrong prefix"), nil
		}
		res, err := jwt.Parse(strings.TrimPrefix(authHeaderValue, "Bearer "),
			func(token *jwt.Token) (i interface{}, e error) {
				if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
					return nil, fmt.Errorf("unexpected signing method: %v", token.Header["alg"])
				}
				return []byte(s.cfg.getTokenKey()), nil
			})
		if err != nil && res == nil {
			return WithDetail(ParseFailed, "parse token failed"), nil
		}
		if !res.Valid {
			return WithDetail(ParseFailed, "invalid token"), nil
		}
		claims, ok := res.Claims.(jwt.MapClaims)
		if !ok {
			return WithDetail(ParseFailed, "parse token failed"), nil
		}
		parsedId, ok := claims["id"].(float64)
		if !ok {
			return WithDetail(ParseFailed, "parse token failed"), nil
		}
		return next(context.WithValue(ctx, "userId", int64(parsedId)), request)
	}
}

func (s *MinterGuruServiceImpl) makeTxOperation(
	ctx context.Context,
	fn func(context.Context, pgx.Tx) (interface{}, bool, *ErrorResponse)) (interface{}, *ErrorResponse) {
	tx, err := s.pool.BeginTx(ctx, pgx.TxOptions{})
	if err != nil {
		return nil, checkAndLogDatabaseError(err)
	}
	defer tx.Rollback(context.Background())
	res, needCommit, e := fn(ctx, tx)
	if needCommit {
		if err := tx.Commit(ctx); err != nil {
			return nil, checkAndLogDatabaseError(err)
		}
	}
	if e != nil {
		return nil, e
	}
	return res, nil
}

func (s *MinterGuruServiceImpl) doPeriodJobs() {
	for {
		next, timeout := toNext()
		select {
		case <-time.After(timeout):
			if err := s.mintRewards(context.Background(), next); err != nil {
				log.Println("mint rewards failed", err)
			}
			break
		case <-s.closeCh:
			return
		}
	}
}

func toNext() (time.Time, time.Duration) {
	now := Now()
	next := now.Add(5 * time.Minute)
	res := truncate(next, 5*time.Minute)
	return res, res.Sub(now)
}

func truncate(t time.Time, duration time.Duration) time.Time {
	return time.Unix(int64(duration.Seconds())*(t.Unix()/int64(duration.Seconds())), 0)
}

func (s *MinterGuruServiceImpl) Stop() error {
	if err := s.server.Close(); err != nil {
		return err
	}
	s.pool.Close()
	s.closeCh <- struct{}{}
	close(s.closeCh)
	return nil
}
