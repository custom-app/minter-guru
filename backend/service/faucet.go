package service

import (
	"context"
	"errors"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/core/types"
	"github.com/ethereum/go-ethereum/crypto"
	"github.com/jackc/pgx/v4"
	"log"
	"math/big"
	"strings"
	"sync"
	"time"
)

var faucetLock = &sync.RWMutex{}

func getUser(ctx context.Context, tx pgx.Tx, id int64) (*User, error) {
	// language=PostgreSQL
	rows, err := tx.Query(ctx, `select id, address from users where id=$1`, id)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	if !rows.Next() {
		return nil, errors.New("user not found")
	}
	user := &User{}
	if err := rows.Scan(&user.Id, &user.Address); err != nil {
		return nil, err
	}
	return user, nil
}

func hasFaucet(ctx context.Context, tx pgx.Tx, userId int64) (bool, error) {
	// language=PostgreSQL
	row := tx.QueryRow(ctx, `select count(*) from faucet_transactions where user_id=$1`, userId)
	var count int
	if err := row.Scan(&count); err != nil {
		return false, err
	}
	return count != 0, nil
}

func (s *MinterGuruServiceImpl) checkUserToFaucet(ctx context.Context, tx pgx.Tx, user *User) *ErrorResponse {
	if gotFaucet, err := hasFaucet(ctx, tx, user.Id); err != nil {
		return checkAndLogDatabaseError(err)
	} else if gotFaucet {
		return AlreadyGotFaucet
	}
	balance, err := s.ethClient.BalanceAt(ctx, common.HexToAddress(user.Address), nil)
	if err != nil {
		return ServiceUnavailable
	}
	if balance.Cmp(big.NewInt(0)) != 0 {
		return BalanceNonZero
	}
	return nil
}

func (s *MinterGuruServiceImpl) transferNativeTokens(ctx context.Context, user *User) (*types.Transaction, *ErrorResponse) {
	privateKey := s.cfg.getFaucetPrivateKey()
	nonce, err := s.ethClient.PendingNonceAt(ctx, crypto.PubkeyToAddress(privateKey.PublicKey))
	if err != nil {
		log.Println("get pending nonce failed", err)
		return nil, ServiceUnavailable
	}
	to := common.HexToAddress(user.Address)
	t, err := types.SignNewTx(privateKey, types.NewEIP155Signer(s.cfg.getChainId()), &types.LegacyTx{
		Nonce:    nonce,
		Gas:      21000,
		GasPrice: big.NewInt(10000000000),
		To:       &to,
		Value:    big.NewInt(0).Mul(s.cfg.getFaucetValue(), big.NewInt(1000000000)),
	})
	if err != nil {
		log.Println("build tx failed", err)
		return nil, ServiceUnavailable
	}
	deadline, _ := ctx.Deadline()
	sendCtx, cancel := context.WithDeadline(ctx, deadline.Add(-2*time.Second))
	defer cancel()
	if err := s.ethClient.SendTransaction(sendCtx, t); err != nil {
		log.Println("send transaction failed", err)
		return nil, ServiceUnavailable
	}
	return t, nil
}

func (s *MinterGuruServiceImpl) faucet(ctx context.Context, tx pgx.Tx, userId int64) (*Transaction, *ErrorResponse) {
	user, err := getUser(ctx, tx, userId)
	if err != nil {
		return nil, checkAndLogDatabaseError(err)
	}
	if e := s.checkUserToFaucet(ctx, tx, user); e != nil {
		return nil, e
	}
	t, e := s.transferNativeTokens(ctx, user)
	if e != nil {
		return nil, e
	}
	// language=PostgreSQL
	if _, err := tx.Exec(ctx, `INSERT INTO faucet_transactions VALUES ($1,$2,$3)`,
		user.Id, Now().UnixMilli(), t.Hash().Hex()); err != nil {
		return nil, checkAndLogDatabaseError(err)
	}
	return &Transaction{
		Id: t.Hash().Hex(),
	}, nil
}

func (s *MinterGuruServiceImpl) Faucet(ctx context.Context, userId int64) (*Transaction, *ErrorResponse) {
	faucetLock.Lock()
	defer faucetLock.Unlock()
	res, e := s.makeTxOperation(ctx, func(ctx context.Context, tx pgx.Tx) (interface{}, bool, *ErrorResponse) {
		res, e := s.faucet(ctx, tx, userId)
		if e != nil {
			return nil, false, e
		}
		return res, true, nil
	})
	if e != nil {
		return nil, e
	}
	return res.(*Transaction), nil
}

func (s *MinterGuruServiceImpl) FaucetByAddress(ctx context.Context, address string) (*Transaction, *ErrorResponse) {
	faucetLock.Lock()
	defer faucetLock.Unlock()
	res, e := s.makeTxOperation(ctx, func(ctx context.Context, tx pgx.Tx) (interface{}, bool, *ErrorResponse) {
		user, e := s.findOrCreateUserWithAddress(ctx, tx, strings.ToLower(address))
		if e != nil {
			return nil, false, e
		}
		res, e := s.faucet(ctx, tx, user.Id)
		if e != nil {
			return nil, false, e
		}
		return res, true, nil
	})
	if e != nil {
		return nil, e
	}
	return res.(*Transaction), nil
}
