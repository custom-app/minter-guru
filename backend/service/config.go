package service

import (
	"crypto/ecdsa"
	"github.com/ethereum/go-ethereum/accounts/abi/bind"
	"github.com/ethereum/go-ethereum/crypto"
	"github.com/fsnotify/fsnotify"
	"github.com/spf13/viper"
	"log"
	"math/big"
	"sync"
)

type Config struct {
	lock                         *sync.RWMutex
	mainCfg, credsCfg, mergedCfg *viper.Viper
}

func NewConfig(path string) (*Config, error) {
	res := &Config{
		lock: &sync.RWMutex{},
	}
	res.mainCfg = viper.New()
	res.mainCfg.AddConfigPath(path)
	if err := res.mainCfg.ReadInConfig(); err != nil {
		return nil, err
	}
	if err := res.loadConfigs(); err != nil {
		return nil, err
	}
	res.mainCfg.WatchConfig()
	res.mainCfg.OnConfigChange(func(in fsnotify.Event) {
		log.Println("main config changed")
		if err := res.loadConfigs(); err != nil {
			log.Println("failed to load configs on change", err)
		}
	})
	return res, nil
}

func (c *Config) loadConfigs() error {
	c.lock.Lock()
	defer c.lock.Unlock()
	credsPath := c.mainCfg.GetString("credentials_path")
	c.credsCfg = viper.New()
	c.credsCfg.AddConfigPath(credsPath)
	if err := c.credsCfg.ReadInConfig(); err != nil {
		return err
	}
	c.credsCfg.WatchConfig()
	c.credsCfg.OnConfigChange(func(in fsnotify.Event) {
		log.Println("creds config changed")
		if err := c.loadConfigs(); err != nil {
			log.Println("failed to load configs on change", err)
		}
	})
	c.mergedCfg = viper.New()
	if err := c.mergedCfg.MergeConfigMap(c.mainCfg.AllSettings()); err != nil {
		return err
	}
	if err := c.mergedCfg.MergeConfigMap(c.credsCfg.AllSettings()); err != nil {
		return err
	}
	return nil
}

func (c *Config) getTokenKey() string {
	c.lock.RLock()
	defer c.lock.RUnlock()
	return c.mergedCfg.GetString("token_key")
}

func (c *Config) getPort() int {
	c.lock.RLock()
	defer c.lock.RUnlock()
	return c.mergedCfg.GetInt("port")
}

func (c *Config) getPgSource() string {
	c.lock.RLock()
	defer c.lock.RUnlock()
	return c.mergedCfg.GetString("pg_source")
}

func (c *Config) getChainId() *big.Int {
	c.lock.RLock()
	defer c.lock.RUnlock()
	return big.NewInt(c.mergedCfg.GetInt64("chain_id"))
}

func (c *Config) GetRPCUrl() string {
	c.lock.RLock()
	defer c.lock.RUnlock()
	return c.mergedCfg.GetString("rpc_url")
}

func (c *Config) getFaucetPrivateKey() *ecdsa.PrivateKey {
	c.lock.RLock()
	defer c.lock.RUnlock()
	faucetKey, err := crypto.HexToECDSA(c.mergedCfg.GetString("faucet.private_key"))
	if err != nil {
		log.Panicln("parse private key failed")
		return nil
	}
	return faucetKey
}

func (c *Config) getFaucetValue() *big.Int {
	c.lock.RLock()
	defer c.lock.RUnlock()
	return big.NewInt(c.mergedCfg.GetInt64("faucet.value"))
}

func (c *Config) getMinterGuruTokenGamingRewardTransactor() *bind.TransactOpts {
	c.lock.RLock()
	defer c.lock.RUnlock()
	privateKey, err := crypto.HexToECDSA(c.mergedCfg.GetString("minter_guru_token.gaming_reward_admin_private_key"))
	if err != nil {
		log.Panicln("parse private key failed", err)
		return nil
	}
	opts, err := bind.NewKeyedTransactorWithChainID(privateKey, big.NewInt(c.mergedCfg.GetInt64("chain_id")))
	if err != nil {
		log.Panicln("build transactor failed", err)
		return nil
	}
	return opts
}

func (c *Config) getMinterGuruTokenAddress() string {
	c.lock.RLock()
	defer c.lock.RUnlock()
	return c.mergedCfg.GetString("minter_guru_token.address")
}

func (c *Config) getMinterGuruTwitterEventId() *big.Int {
	c.lock.RLock()
	defer c.lock.RUnlock()
	return big.NewInt(c.mergedCfg.GetInt64("minter_guru_token.event_id"))
}

func (c *Config) getMinterGuruTwitterDailyLimit() int {
	c.lock.RLock()
	defer c.lock.RUnlock()
	return c.mergedCfg.GetInt("minter_guru_token.twitter_daily_limit")
}
