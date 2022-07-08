package service

import (
	"context"
	"github.com/ethereum/go-ethereum/accounts/abi/bind"
	"github.com/ethereum/go-ethereum/common"
	"github.com/jackc/pgx/v4"
	"log"
	"math/big"
	"sync"
	"time"
)

var twitterLock = &sync.RWMutex{}

func (s *MinterGuruServiceImpl) ApplyForTwitterReward(ctx context.Context,
	userId int64) (*TwitterReward, *ErrorResponse) {
	twitterLock.Lock()
	defer twitterLock.Unlock()
	res, e := s.makeTxOperation(ctx, func(ctx context.Context, tx pgx.Tx) (interface{}, bool, *ErrorResponse) {
		now := time.Now().UnixMilli()
		// language=PostgreSQL
		row := tx.QueryRow(ctx, `SELECT COUNT(*) FROM twitter_rewards WHERE user_id=$1 AND created_at>=$2`,
			userId, now)
		var count int
		if err := row.Scan(&count); err != nil {
			return nil, false, checkAndLogDatabaseError(err)
		}
		if count >= s.cfg.getMinterGuruTwitterDailyLimit() {
			return nil, false, TwitterLimitReached
		}
		// language=PostgreSQL
		row = tx.QueryRow(ctx, `INSERT INTO twitter_rewards VALUES (DEFAULT,$1,$2)`, userId, now)
		res := &TwitterReward{
			CreatedAt: now,
		}
		if err := row.Scan(&res.Id); err != nil {
			return nil, false, checkAndLogDatabaseError(err)
		}
		return res, true, nil
	})
	if e != nil {
		return nil, e
	}
	return res.(*TwitterReward), nil
}

func (s *MinterGuruServiceImpl) GetTwitterRewards(ctx context.Context,
	userId int64) ([]*TwitterReward, *ErrorResponse) {
	twitterLock.RLock()
	defer twitterLock.RUnlock()
	res, e := s.makeTxOperation(ctx, func(ctx context.Context, tx pgx.Tx) (interface{}, bool, *ErrorResponse) {
		// language=PostgreSQL
		rows, err := tx.Query(ctx, `SELECT id, created_at, coalesce(txid, '') FROM twitter_rewards 
                                          WHERE user_id=$1 ORDER BY id DESC`, userId)
		if err != nil {
			return nil, false, checkAndLogDatabaseError(err)
		}
		defer rows.Close()
		var res []*TwitterReward
		for rows.Next() {
			r := &TwitterReward{
				Transaction: &Transaction{},
			}
			if err := rows.Scan(&r.Id, &r.CreatedAt, &r.Transaction.Id); err != nil {
				return nil, false, checkAndLogDatabaseError(err)
			}
			if r.Transaction.Id == "" {
				r.Transaction = nil
			}
			res = append(res, r)
		}
		return res, true, nil
	})
	if e != nil {
		return nil, e
	}
	return res.([]*TwitterReward), nil
}

func getRecordsToMint(ctx context.Context, tx pgx.Tx, now time.Time) ([]int64, []common.Address, error) {
	// language=PostgreSQL
	rows, err := tx.Query(ctx, `SELECT tr.id,u.address FROM twitter_rewards AS tr JOIN users u on tr.user_id = u.id 
             WHERE txid IS NULL AND created_at<=$1`, now.AddDate(0, 0, -1).UnixMilli())
	if err != nil {
		return nil, nil, err
	}
	defer rows.Close()
	var (
		recordIds []int64
		addresses []common.Address
	)
	for rows.Next() {
		var (
			id      int64
			address string
		)
		if err := rows.Scan(&id, &address); err != nil {
			return nil, nil, err
		}
		recordIds, addresses = append(recordIds, id), append(addresses, common.HexToAddress(address))
	}
	return recordIds, addresses, nil
}

func (s *MinterGuruServiceImpl) mintBatchRewards(ids []int64, addresses []common.Address) {
	eventId := s.cfg.getMinterGuruTwitterEventId()
	canMintCount, err := s.tokenInstance.CanMint(nil, eventId, big.NewInt(int64(len(addresses))))
	if err != nil {
		log.Println("can mint call failed", err)
		return
	}
	count := canMintCount.Int64()
	if count == 0 {
		log.Println("can mint count is equal to 0")
		return
	}
	if count < int64(len(addresses)) {
		ids, addresses = ids[:count], addresses[:count]
	}
	opts, err := bind.NewKeyedTransactorWithChainID(s.cfg.getMinterGuruTokenPrivateKey(), s.cfg.getChainId())
	if err != nil {
		log.Println("build transactor failed", err)
		return
	}
	tx, err := s.tokenInstance.MintGamingAwardForMultiple(opts, eventId, addresses)
	if err != nil {
		log.Println("mint gaming reward failed", err)
		return
	}
	log.Println("reward minted", tx.Hash().Hex())
	// language=PostgreSQL
	_, err = s.pool.Exec(context.Background(), `update twitter_rewards set txid=$1 where id=any($2)`,
		tx.Hash().Hex(), ids)
	if err != nil {
		log.Println("save gaming reward failed", err)
		return
	}
}

func (s *MinterGuruServiceImpl) mintRewards(ctx context.Context, now time.Time) error {
	twitterLock.Lock()
	defer twitterLock.Unlock()
	tx, err := s.pool.BeginTx(ctx, pgx.TxOptions{})
	if err != nil {
		return err
	}
	defer tx.Rollback(context.Background())
	ids, addresses, err := getRecordsToMint(ctx, tx, now)
	if err != nil {
		return err
	}
	if err := tx.Commit(ctx); err != nil {
		return err
	}
	const step = 100
	for i := 0; i < len(ids); i += step {
		if step*(i+1) < len(ids) {
			s.mintBatchRewards(ids[i*step:(i+1)*step], addresses[i*step:(i+1)*step])
		} else {
			s.mintBatchRewards(ids[i*step:], addresses[i*step:])
		}
	}
	return nil
}
