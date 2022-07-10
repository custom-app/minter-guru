package service

import (
	"context"
	"github.com/ethereum/go-ethereum/accounts/abi/bind/backends"
	"github.com/google/go-cmp/cmp"
	"path/filepath"
	"testing"
	"time"
)

func twitterNow() time.Time {
	return time.UnixMilli(1633104919718)
}

func TestGetTwitterRewards(t *testing.T) {
	NowWrap(t, twitterNow, func(t *testing.T) {
		GooseWrap(t, filepath.Join("tests", "twitter"), func(t *testing.T) {
			ServiceWrap(t, func(t *testing.T, impl *MinterGuruServiceImpl) {
				res, e := impl.GetTwitterRewards(context.Background(), 1)
				if e != nil {
					t.Errorf("get twitter rewards failed with error: %+v", e)
					return
				}
				if d := cmp.Diff(res, []*TwitterReward{
					{
						Id:          4,
						CreatedAt:   1633104919718 - 32*3600*1000,
						Transaction: nil,
					},
					{
						Id:        3,
						CreatedAt: 1633104919718 - 30*3600*1000,
						Transaction: &Transaction{
							Id: "0x6dec884c0e8f69f40a4cd2a9d90e704673358fb6534fa988d66a06523a64d55b",
						},
					},
					{
						Id:          2,
						CreatedAt:   1633104919718 - 18*3600*1000,
						Transaction: nil,
					},
					{
						Id:          1,
						CreatedAt:   1633104919718 - 12*3600*1000,
						Transaction: nil,
					},
				}); d != "" {
					t.Errorf("get twitter rewards unmatch: %s", d)
					return
				}
			})
		})
	})
}

func TestApplyForTwitterReward(t *testing.T) {
	NowWrap(t, twitterNow, func(t *testing.T) {
		GooseWrap(t, filepath.Join("tests", "twitter"), func(t *testing.T) {
			ServiceWrap(t, func(t *testing.T, impl *MinterGuruServiceImpl) {
				res, e := impl.ApplyForTwitterReward(context.Background(), 1)
				if e != nil {
					t.Errorf("apply for twitter reward failed with error: %+v", e)
					return
				}
				if d := cmp.Diff(res, &TwitterReward{
					Id:          11,
					CreatedAt:   1633104919718,
					Transaction: nil,
				}); d != "" {
					t.Errorf("apply for twitter res unmatch: %s", d)
					return
				}
			})
		})
	})
}

func TestApplyForTwitterRewardLimitReached(t *testing.T) {
	NowWrap(t, twitterNow, func(t *testing.T) {
		GooseWrap(t, filepath.Join("tests", "twitter"), func(t *testing.T) {
			ServiceWrap(t, func(t *testing.T, impl *MinterGuruServiceImpl) {
				res, e := impl.ApplyForTwitterReward(context.Background(), 2)
				if res != nil {
					t.Errorf("apply for twitter reward with error res not empty: %+v", res)
					return
				}
				if d := cmp.Diff(e, TwitterLimitReached); d != "" {
					t.Errorf("apply for twitter reward limit reached error unmatch: %s", d)
					return
				}
			})
		})
	})
}

func TestMintRewardTokens(t *testing.T) {
	NowWrap(t, twitterNow, func(t *testing.T) {
		GooseWrap(t, filepath.Join("tests", "twitter"), func(t *testing.T) {
			ServiceWithBlockchainAndTokenWrap(t, func(t *testing.T,
				sim *backends.SimulatedBackend, impl *MinterGuruServiceImpl) {
				if err := impl.mintRewards(context.Background(), twitterNow()); err != nil {
					t.Errorf("mint rewards failed: %s", err)
					return
				}
				sim.Commit()
				res, e := impl.GetTwitterRewards(context.Background(), 4)
				if e != nil {
					t.Errorf("get twitter rewards after mint failed with error: %+v", e)
					return
				}
				if len(res) != 2 {
					t.Errorf("get twitter rewards after mint res size unmatch: %d", len(res))
					return
				}
				if res[0].Transaction == nil {
					t.Errorf("get twitter rewards after mint nil transaction")
					return
				}
				if d := cmp.Diff(res, []*TwitterReward{
					{
						Id:        10,
						CreatedAt: 1633104919718 - 28*3600*1000,
						Transaction: &Transaction{
							Id: res[0].Transaction.Id,
						},
					},
					{
						Id:        9,
						CreatedAt: 1633104919718 - 29*3600*1000,
						Transaction: &Transaction{
							Id: res[0].Transaction.Id,
						},
					},
				}); d != "" {
					t.Errorf("get twitter rewards after mint unmatch: %s", d)
					return
				}
			})
		})
	})
}
