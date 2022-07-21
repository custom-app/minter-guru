// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers } from "hardhat";
import { Signer, BigNumber as BN } from "ethers";
import {
  MinterGuruPublicCollection,
  // eslint-disable-next-line camelcase
  MinterGuruPublicCollection__factory,
  MinterGuruPublicCollectionsRouter,
  // eslint-disable-next-line camelcase
  MinterGuruPublicCollectionsRouter__factory,
  // eslint-disable-next-line node/no-missing-import
} from "../typechain";
// eslint-disable-next-line node/no-missing-import
import { createPrivateCollectionsAccessToken, createMinterGuruToken } from "./util";

async function createPublicRouter(account: Signer) {
  const factory = new MinterGuruPublicCollection__factory(account);
  const impl: MinterGuruPublicCollection = await factory.deploy();

  const routerFactory = new MinterGuruPublicCollectionsRouter__factory(account);
  const router: MinterGuruPublicCollectionsRouter = await routerFactory.deploy(
    impl.address
  );
  console.log("MinterGuruPublicCollectionsRouter: ", router.address);

  const genRanHex = (size: number) =>
    [...Array(size)]
      .map(() => Math.floor(Math.random() * 16).toString(16))
      .join("");
  await router.createCollectionClone("0x" + genRanHex(64), "test", "TEST");
}

async function main() {
  const accounts: Signer[] = await ethers.getSigners();
  await createPublicRouter(accounts[0]);
  const tokenAddress = await createMinterGuruToken(accounts);
  console.log("MinterGuruToken: ", tokenAddress);
  const accessTokenInstance = await createPrivateCollectionsAccessToken(
    accounts[0],
    tokenAddress
  );
  console.log("MinterGuruAccessToken: ", accessTokenInstance.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
