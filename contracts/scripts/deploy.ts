// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers } from "hardhat";
import { Signer, BigNumber as BN } from "ethers";
import {
  MinterGuruCollectionsAccessToken,
  // eslint-disable-next-line camelcase
  MinterGuruCollectionsAccessToken__factory,
  MinterGuruPrivateCollection,
  // eslint-disable-next-line camelcase
  MinterGuruPrivateCollection__factory,
  MinterGuruPublicCollection,
  // eslint-disable-next-line camelcase
  MinterGuruPublicCollection__factory,
  MinterGuruPublicCollectionsRouter,
  // eslint-disable-next-line camelcase
  MinterGuruPublicCollectionsRouter__factory,
  MinterGuruToken,
  // eslint-disable-next-line camelcase
  MinterGuruToken__factory,
  // eslint-disable-next-line node/no-missing-import
} from "../typechain";

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

async function createMinterGuruToken(accounts: Signer[]): Promise<string> {
  const factory = new MinterGuruToken__factory(accounts[0]);
  const multiplier = BN.from(10).pow(BN.from(18));
  const instance: MinterGuruToken = await factory.deploy(
    BN.from(100000).mul(multiplier),
    BN.from(50000).mul(multiplier),
    BN.from(20000).mul(multiplier),
    BN.from(30000).mul(multiplier),
    await accounts[1].getAddress(),
    await accounts[2].getAddress(),
    await accounts[3].getAddress()
  );
  console.log("MinterGuruToken: ", instance.address);
  return instance.address;
}

async function createPrivateCollectionsAccessToken(
  account: Signer,
  tokenAddress: string
) {
  const factory = new MinterGuruPrivateCollection__factory(account);
  const impl: MinterGuruPrivateCollection = await factory.deploy();
  const accessTokenFactory = new MinterGuruCollectionsAccessToken__factory(
    account
  );
  const multiplier = BN.from(10).pow(BN.from(18));
  const instance: MinterGuruCollectionsAccessToken =
    await accessTokenFactory.deploy(
      "MinterGuruAccessToken",
      "MIGUAT",
      tokenAddress,
      impl.address,
      BN.from(1).mul(multiplier)
    );
  console.log("MinterGuruAccessToken: ", instance.address);
}

async function main() {
  const accounts: Signer[] = await ethers.getSigners();
  await createPublicRouter(accounts[0]);
  const tokenAddress = await createMinterGuruToken(accounts);
  await createPrivateCollectionsAccessToken(accounts[0], tokenAddress);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
