package service

import (
	"context"
	"fmt"
	"github.com/dgrijalva/jwt-go"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/crypto"
	"github.com/jackc/pgx/v4"
	"log"
	"math/rand"
	"strings"
	"sync"
	"time"
)

const (
	authMessageFormat = "Hello, %s! Please, sign this message with random param %d to use MinterGuru application!"
	codeLifetime      = 3 * time.Minute
)

var authLock = &sync.Mutex{}

func init() {
	rand.Seed(Now().UnixNano())
}

func (s *MinterGuruServiceImpl) GetAuthMessage(ctx context.Context, address string) (*AuthMessageResponse, *ErrorResponse) {
	authLock.Lock()
	defer authLock.Unlock()
	res, e := s.makeTxOperation(ctx, func(ctx context.Context, tx pgx.Tx) (interface{}, bool, *ErrorResponse) {
		addr := strings.ToLower(address)
		msg := fmt.Sprintf(authMessageFormat, addr, 1_000_000_000+rand.Int63n(9_000_000_000))
		// language=PostgreSQL
		if _, err := tx.Exec(ctx, `insert into auth_messages values($1,$2,$3) 
			on conflict on constraint auth_messages_pkey do update set code=$2,created_at=$3`,
			addr, msg, Now().UnixMilli()); err != nil {
			return nil, false, checkAndLogDatabaseError(err)
		}
		return &AuthMessageResponse{
			Message: msg,
		}, true, nil
	})
	if e != nil {
		return nil, e
	}
	return res.(*AuthMessageResponse), nil
}

func (s *MinterGuruServiceImpl) loadSignatureCode(ctx context.Context, tx pgx.Tx, address string) (string, *ErrorResponse) {
	// language=PostgreSQL
	dropReq, err := tx.Query(ctx, "delete from auth_messages where address=$1 returning code,created_at", address)
	if err != nil {
		return "", checkAndLogDatabaseError(err)
	}
	defer dropReq.Close()
	if !dropReq.Next() {
		return "", CodeNotFound
	}
	var (
		code      string
		createdAt int64
	)
	if err := dropReq.Scan(&code, &createdAt); err != nil {
		return "", checkAndLogDatabaseError(err)
	}
	if createdAt+codeLifetime.Milliseconds() < Now().UnixMilli() {
		return "", CodeExpired
	}
	return code, nil
}

func verifySignature(code, address, signature string) *ErrorResponse {
	hash := crypto.Keccak256([]byte(fmt.Sprintf("\x19Ethereum Signed Message:\n%d%s", len(code), code)))
	sig := common.FromHex(signature)
	if sig[len(sig)-1] > 4 {
		sig[len(sig)-1] -= 27
	}
	pubKey, err := crypto.Ecrecover(hash, sig)
	if err != nil {
		log.Println("ecrecover failed", err)
		return InternalError
	}
	pkey, err := crypto.UnmarshalPubkey(pubKey)
	if err != nil {
		log.Println("decompress pubkey failed", err)
		return InternalError
	}
	signedAddress := crypto.PubkeyToAddress(*pkey)
	if strings.ToLower(signedAddress.Hex()) != address {
		return WrongSignature
	}
	return nil
}

func (s *MinterGuruServiceImpl) findOrCreateUserWithAddress(
	ctx context.Context, tx pgx.Tx, address string) (*User, *ErrorResponse) {
	// language=PostgreSQL
	res, err := tx.Query(ctx, `SELECT id,address FROM users WHERE address=$1`, strings.ToLower(address))
	if err != nil {
		return nil, checkAndLogDatabaseError(err)
	}
	defer res.Close()
	if res.Next() {
		user := &User{}
		if err := res.Scan(&user.Id, &user.Address); err != nil {
			return nil, checkAndLogDatabaseError(err)
		}
		return user, nil
	}
	res.Close()
	// language=PostgreSQL
	insertRes := tx.QueryRow(ctx, `INSERT INTO users VALUES(DEFAULT,$1) RETURNING id`, address)
	user := &User{
		Address: address,
	}
	if err := insertRes.Scan(&user.Id); err != nil {
		return nil, checkAndLogDatabaseError(err)
	}
	return user, nil
}

func (s *MinterGuruServiceImpl) createToken(userId int64, expiresAt time.Time) (string, error) {
	claims := jwt.MapClaims{
		"userId": userId,
		"exp":    expiresAt.Unix(),
	}
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString([]byte(s.cfg.getTokenKey()))
}

func (s *MinterGuruServiceImpl) Auth(ctx context.Context, address string, signature string) (*AuthResponse, *ErrorResponse) {
	authLock.Lock()
	defer authLock.Unlock()
	res, e := s.makeTxOperation(ctx, func(ctx context.Context, tx pgx.Tx) (interface{}, bool, *ErrorResponse) {
		code, e := s.loadSignatureCode(ctx, tx, address)
		if e != nil {
			return nil, false, e
		}
		if e := verifySignature(code, address, signature); e != nil {
			return nil, false, e
		}
		c, e := s.findOrCreateUserWithAddress(ctx, tx, address)
		if e != nil {
			return nil, false, e
		}
		expiresAt := Now().AddDate(0, 0, 7)
		token, err := s.createToken(c.Id, expiresAt)
		if err != nil {
			return nil, false, InternalError
		}
		return &AuthResponse{
			User: c,
			AccessToken: &TokenData{
				Token:     token,
				ExpiresAt: expiresAt.UnixMilli(),
			},
		}, true, nil
	})
	if e != nil {
		return nil, e
	}
	return res.(*AuthResponse), nil
}
