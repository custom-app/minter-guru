#!/usr/bin/env bash

PATH=$PATH:/home/$(whoami)/go/bin
mkdir -p contracts/build
cd ../contracts || exit
yarn hardhat compile || exit
cp -r artifacts/contracts/* ../backend/contracts/build || exit
cd ../backend/contracts || exit

mkdir -p public_collection
jq ".abi" build/MinterGuruPublicCollection.sol/MinterGuruPublicCollection.json > build/MinterGuruPublicCollection.sol/MinterGuruPublicCollection.abi
abigen --abi build/MinterGuruPublicCollection.sol/MinterGuruPublicCollection.abi \
  --pkg public_collection \
  --type MinterGuruPublicCollection \
  --out public_collection/public_collection.go

mkdir -p private_collection
jq ".abi" build/MinterGuruPrivateCollection.sol/MinterGuruPrivateCollection.json > build/MinterGuruPrivateCollection.sol/MinterGuruPrivateCollection.abi
abigen --abi build/MinterGuruPrivateCollection.sol/MinterGuruPrivateCollection.abi \
  --pkg private_collection \
  --type MinterGuruPrivateCollection \
  --out private_collection/private_collection.go

mkdir -p public_collections_router
jq ".abi" build/MinterGuruPublicCollectionsRouter.sol/MinterGuruPublicCollectionsRouter.json > build/MinterGuruPublicCollectionsRouter.sol/MinterGuruPublicCollectionsRouter.abi
abigen --abi build/MinterGuruPublicCollectionsRouter.sol/MinterGuruPublicCollectionsRouter.abi \
  --pkg public_collections_router \
  --type MinterGuruPublicCollectionsRouter \
  --out public_collections_router/public_collections_router.go

mkdir -p collections_access_token
jq ".abi" build/MinterGuruCollectionsAccessToken.sol/MinterGuruCollectionsAccessToken.json > build/MinterGuruCollectionsAccessToken.sol/MinterGuruCollectionsAccessToken.abi
abigen --abi build/MinterGuruCollectionsAccessToken.sol/MinterGuruCollectionsAccessToken.abi \
  --pkg collections_access_token \
  --type MinterGuruCollectionsAccessToken \
  --out collections_access_token/collections_access_token.go

mkdir -p migu_token
jq ".abi" build/MinterGuruToken.sol/MinterGuruToken.json > build/MinterGuruToken.sol/MinterGuruToken.abi
abigen --abi build/MinterGuruToken.sol/MinterGuruToken.abi \
  --pkg migu_token \
  --type MinterGuruToken \
  --out migu_token/migu_token.go

cd ../ || exit