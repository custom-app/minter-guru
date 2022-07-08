package main

import (
	"context"
	"flag"
	"github.com/custom-app/crypto-insta/backend/service"
	"github.com/ethereum/go-ethereum/ethclient"
	"log"
	"os"
	"os/signal"
	"syscall"
)

func main() {
	var cfgPath string
	flag.StringVar(&cfgPath, "cfg", "", "")
	flag.Parse()
	cfg, err := service.NewConfig(cfgPath)
	if err != nil {
		log.Panicln(err)
	}
	client, err := ethclient.Dial(cfg.GetRPCUrl())
	if err != nil {
		log.Panicln(err)
	}
	s, err := service.NewMinterGuruServiceImpl(cfg, client)
	if err != nil {
		log.Panicln(err)
	}
	if err := s.Start(context.Background()); err != nil {
		log.Panicln(err)
	}

	stopChan := make(chan os.Signal, 1)
	signal.Notify(stopChan, syscall.SIGTERM, syscall.SIGINT)
	<-stopChan

	if err := s.Stop(); err != nil {
		log.Panicln(err)
	}
}
