package service

import (
	"github.com/ethereum/go-ethereum/accounts/abi/bind/backends"
	"path/filepath"
	"testing"
)

func TestGetTwitterRewards(t *testing.T) {
	NowWrap(t, authNow, func(t *testing.T) {
		GooseWrap(t, filepath.Join("tests", "faucet"), func(t *testing.T) {
			ServiceWrap(t, func(t *testing.T, impl *MinterGuruServiceImpl) {

			})
		})
	})
}

func TestApplyForTwitterReward(t *testing.T) {
	NowWrap(t, authNow, func(t *testing.T) {
		GooseWrap(t, filepath.Join("tests", "faucet"), func(t *testing.T) {
			ServiceWrap(t, func(t *testing.T, impl *MinterGuruServiceImpl) {

			})
		})
	})
}

func TestApplyForTwitterRewardLimitReached(t *testing.T) {
	NowWrap(t, authNow, func(t *testing.T) {
		GooseWrap(t, filepath.Join("tests", "faucet"), func(t *testing.T) {
			ServiceWrap(t, func(t *testing.T, impl *MinterGuruServiceImpl) {

			})
		})
	})
}

func TestMintRewardTokens(t *testing.T) {
	NowWrap(t, authNow, func(t *testing.T) {
		GooseWrap(t, filepath.Join("tests", "faucet"), func(t *testing.T) {
			ServiceWithBlockchainAndTokenWrap(t, func(t *testing.T,
				sim *backends.SimulatedBackend, impl *MinterGuruServiceImpl) {

			})
		})
	})
}
