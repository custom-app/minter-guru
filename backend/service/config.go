package service

import (
	"github.com/fsnotify/fsnotify"
	"github.com/spf13/viper"
	"log"
	"sync"
)

type config struct {
	lock                         *sync.RWMutex
	mainCfg, credsCfg, mergedCfg *viper.Viper
}

func newConfig(path string) (*config, error) {
	res := &config{
		lock: &sync.RWMutex{},
	}
	res.mainCfg = viper.New()
	res.mainCfg.WatchConfig()
	res.mainCfg.AddConfigPath(path)
	if err := res.mainCfg.ReadInConfig(); err != nil {
		return nil, err
	}
	res.mainCfg.WatchConfig()
	res.mainCfg.OnConfigChange(func(in fsnotify.Event) {
		if err := res.loadConfigs(); err != nil {
			log.Println("failed to load configs on change", err)
		}
	})
	return res, nil
}

func (c *config) loadConfigs() error {
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

func (c *config) getTokenKey() string {
	c.lock.RLock()
	defer c.lock.RUnlock()
	return c.mergedCfg.GetString("token_key")
}

func (c *config) getPort() int {
	c.lock.RLock()
	defer c.lock.RUnlock()
	return c.mergedCfg.GetInt("port")
}
