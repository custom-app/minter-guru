package service

import (
	"context"
	"github.com/ethereum/go-ethereum/accounts/abi/bind/backends"
	"github.com/google/go-cmp/cmp"
	"path/filepath"
	"regexp"
	"testing"
)

func TestFaucet(t *testing.T) {
	NowWrap(t, authNow, func(t *testing.T) {
		GooseWrap(t, filepath.Join("tests", "faucet"), func(t *testing.T) {
			ServiceWithBlockchainWrap(t, func(t *testing.T,
				sim *backends.SimulatedBackend, impl *MinterGuruServiceImpl) {
				res, e := impl.Faucet(context.Background(), 5)
				if e != nil {
					t.Errorf("faucet failed: %+v", e)
					return
				}
				sim.Commit()
				if !regexp.MustCompile("^0x[a-fA-F\\d]{64}$").MatchString(res.Id) {
					t.Errorf("faucet wrong txid: %s", res.Id)
					return
				}
			})
		})
	})
}

func testFaucetNonZeroBalance(_ *backends.SimulatedBackend, impl *MinterGuruServiceImpl) func(*testing.T) {
	return func(t *testing.T) {
		res, e := impl.Faucet(context.Background(), 1)
		if res != nil {
			t.Errorf("faucet non zero balance not empty result: %+v", res)
			return
		}
		if d := cmp.Diff(e, BalanceNonZero); d != "" {
			t.Errorf("faucet non zero balance error unmatch: %s", d)
			return
		}
	}
}

func testFaucetAlreadyGot(_ *backends.SimulatedBackend, impl *MinterGuruServiceImpl) func(*testing.T) {
	return func(t *testing.T) {
		res, e := impl.Faucet(context.Background(), 2)
		if res != nil {
			t.Errorf("faucet already got not empty result: %+v", res)
			return
		}
		if d := cmp.Diff(e, AlreadyGotFaucet); d != "" {
			t.Errorf("faucet already got error unmatch: %s", d)
			return
		}
	}
}

func TestFaucetErrors(t *testing.T) {
	NowWrap(t, authNow, func(t *testing.T) {
		GooseWrap(t, filepath.Join("tests", "faucet"), func(t *testing.T) {
			ServiceWithBlockchainWrap(t, func(t *testing.T,
				sim *backends.SimulatedBackend, impl *MinterGuruServiceImpl) {
				t.Run("TestFaucetNonZeroBalance", testFaucetNonZeroBalance(sim, impl))
				t.Run("TestFaucetAlreadyGot", testFaucetAlreadyGot(sim, impl))
			})
		})
	})
}
