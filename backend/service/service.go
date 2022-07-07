package service

import (
	"context"
	"fmt"
	"github.com/dgrijalva/jwt-go"
	"github.com/go-kit/kit/endpoint"
	httptransport "github.com/go-kit/kit/transport/http"
	"github.com/gorilla/mux"
	"log"
	"net/http"
	"strings"
)

type TokenData struct {
	Token     string `json:"token"`
	ExpiresAt int64  `json:"expiresAt"`
}

type User struct {
	Address string `json:"address"`
	Id      int64  `json:"id"`
}

type FaucetTransaction struct {
	Id        string `json:"id"`
	Timestamp int64  `json:"timestamp"`
}

type FaucetRecord struct {
	Id          int64              `json:"id"`
	CreatedAt   int64              `json:"createdAt"`
	Transaction *FaucetTransaction `json:"transaction"`
}

type MinterGuruService interface {
	GetAuthMessage(context.Context, string) (string, *ErrorResponse)
	Auth(context.Context, string, string) (*User, *ErrorResponse)
	GetFaucetRecords(context.Context, int64) ([]*FaucetRecord, *ErrorResponse)
	Faucet(context.Context, int64) (*FaucetRecord, *ErrorResponse)
}

type MinterGuruServiceImpl struct {
	cfg     *config
	server  *http.Server
	closeCh chan struct{}
}

func NewMinterGuruServiceImpl(cfgPath string) (*MinterGuruServiceImpl, error) {
	cfg, err := newConfig(cfgPath)
	if err != nil {
		return nil, err
	}
	res := &MinterGuruServiceImpl{
		closeCh: make(chan struct{}),
		cfg:     cfg,
	}
	return res, nil
}

func (s *MinterGuruServiceImpl) Start() {
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
	getRecordsHandler := httptransport.NewServer(
		s.authMiddleware(makeGetFaucetRecordsEndpoint(s)),
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

	faucetRouter := router.PathPrefix("/faucet").Methods(http.MethodPost).Subrouter()
	faucetRouter.Handle("/get_records", getRecordsHandler)
	faucetRouter.Handle("", faucetHandler)

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
}

func (s *MinterGuruServiceImpl) authMiddleware(next endpoint.Endpoint) endpoint.Endpoint {
	return func(ctx context.Context, request interface{}) (interface{}, error) {
		authHeaderValue, ok := ctx.Value(httptransport.ContextKeyRequestAuthorization).(string)
		if !ok {

		}
		if !strings.HasPrefix(authHeaderValue, "Bearer ") {

		}
		res, err := jwt.Parse(strings.TrimPrefix(authHeaderValue, "Bearer "),
			func(token *jwt.Token) (i interface{}, e error) {
				if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
					return nil, fmt.Errorf("unexpected signing method: %v", token.Header["alg"])
				}
				return []byte(s.cfg.getTokenKey()), nil
			})
		if err != nil && res == nil {

		}
		if !res.Valid {

		}
		claims, ok := res.Claims.(jwt.MapClaims)
		if !ok {

		}
		parsedId, ok := claims["id"].(float64)
		if !ok {

		}
		return next(context.WithValue(ctx, "userId", int64(parsedId)), request)
	}
}

func (s *MinterGuruServiceImpl) doPeriodJobs() {

}

func (s *MinterGuruServiceImpl) Stop() error {
	if err := s.server.Close(); err != nil {
		return err
	}
	s.closeCh <- struct{}{}
	close(s.closeCh)
	return nil
}
