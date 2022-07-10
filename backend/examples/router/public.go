package main

import (
	"flag"
	"fmt"
	"github.com/custom-app/minter-guru/backend/contracts/public_collections_router"
	"github.com/ethereum/go-ethereum/accounts/abi/bind"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/ethclient"
	"github.com/ethereum/go-ethereum/rpc"
	"log"
	"math/big"
	"net/http"
)

func main() {
	var url, router, caller string
	flag.StringVar(&url, "url", "", "")
	flag.StringVar(&router, "router", "", "")
	flag.StringVar(&caller, "caller", "", "")
	flag.Parse()

	rpcClient, err := rpc.DialHTTPWithClient(url, http.DefaultClient)
	if err != nil {
		log.Panicln(err)
	}
	c := ethclient.NewClient(rpcClient)
	routerInstance, err := public_collections_router.NewMinterGuruPublicCollectionsRouter(common.HexToAddress(router), c)
	if err != nil {
		log.Panicln(err)
	}
	res, err := routerInstance.GetSelfPublicTokens(&bind.CallOpts{
		From: common.HexToAddress(caller),
	}, big.NewInt(0), big.NewInt(1))
	if err != nil {
		log.Panicln(err)
	}
	fmt.Printf("collections: %+v\n", res.CollectionsRes)
	fmt.Printf("tokens: %+v: \n", res.TokensRes)
	fmt.Printf("total: %v\n", res.Total)
}
