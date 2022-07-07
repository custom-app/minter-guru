package main

import (
	"flag"
	"fmt"
	"github.com/custom-app/crypto-insta/backend/contracts/migu_token"
	"github.com/ethereum/go-ethereum/accounts/abi/bind"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/ethclient"
	"github.com/ethereum/go-ethereum/rpc"
	"log"
	"net/http"
)

func main() {
	var url, contract, caller string
	flag.StringVar(&url, "url", "", "")
	flag.StringVar(&contract, "contract", "", "")
	flag.StringVar(&caller, "caller", "", "")
	flag.Parse()

	rpcClient, err := rpc.DialHTTPWithClient(url, http.DefaultClient)
	if err != nil {
		log.Panicln(err)
	}
	c := ethclient.NewClient(rpcClient)
	tokenInstance, err := migu_token.NewMinterGuruToken(common.HexToAddress(contract), c)
	if err != nil {
		log.Panicln(err)
	}
	res, err := tokenInstance.BalanceOf(&bind.CallOpts{
		From: common.HexToAddress(caller),
	}, common.HexToAddress(caller))
	if err != nil {
		log.Panicln(err)
	}
	fmt.Printf("balance: %+v\n", res)
}
