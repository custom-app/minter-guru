// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers } from "hardhat";
import { Signer, BigNumber as BN } from "ethers";
import {
  MinterGuruCollectionsAccessToken,
  MinterGuruPublicCollection,
  // eslint-disable-next-line camelcase
  MinterGuruPublicCollection__factory,
  MinterGuruPublicCollectionsRouter,
  // eslint-disable-next-line camelcase
  MinterGuruPublicCollectionsRouter__factory,
  // eslint-disable-next-line node/no-missing-import
} from "../typechain";
// eslint-disable-next-line node/no-missing-import
import {
  createPrivateCollectionsAccessToken,
  createMinterGuruToken,
} from "./util";

async function createPublicRouter(account: Signer, metaUri: string) {
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
  await router.createCollectionClone(
    "0x" + genRanHex(64),
    "Minter Guru Public Collection",
    "MIGUPC",
    metaUri
  );
}

async function main() {
  const network = process.env.HARDHAT_NETWORK;
  const accounts: Signer[] = await ethers.getSigners();

  if (network === "polygon") {
    await createPublicRouter(
      accounts[0],
      "ipfs://bafkreifug2publpbhjbupqfuk634frihq3fth2qeodtnxqyb7coopxioui"
    );
  } else {
    await createPublicRouter(
      accounts[0],
      "ipfs://bafkreifug2publpbhjbupqfuk634frihq3fth2qeodtnxqyb7coopxioui"
    );
  }

  let tokenAddress: string;
  const multiplier = BN.from(10).pow(BN.from(18));
  if (network === "polygon") {
    tokenAddress = await createMinterGuruToken(
      accounts,
      BN.from(25000000).mul(multiplier),
      BN.from(7500000).mul(multiplier),
      BN.from(5000000).mul(multiplier),
      BN.from(12500000).mul(multiplier)
    );
  } else {
    tokenAddress = await createMinterGuruToken(
      accounts,
      BN.from(100000).mul(multiplier),
      BN.from(50000).mul(multiplier),
      BN.from(20000).mul(multiplier),
      BN.from(30000).mul(multiplier)
    );
  }
  console.log("MinterGuruToken: ", tokenAddress);
  let accessTokenInstance: MinterGuruCollectionsAccessToken;

  if (network === "polygon") {
    accessTokenInstance = await createPrivateCollectionsAccessToken(
      accounts[0],
      tokenAddress,
      "ipfs://bafkreicyphjyqqlxjzqlllwnxth3zqdoj3mkteeia46iyueuolgyzjzagm",
      BN.from(35).mul(multiplier)
    );
  } else {
    accessTokenInstance = await createPrivateCollectionsAccessToken(
      accounts[0],
      tokenAddress,
      "ipfs://bafkreicyphjyqqlxjzqlllwnxth3zqdoj3mkteeia46iyueuolgyzjzagm",
      BN.from(1).mul(multiplier)
    );
  }
  console.log("MinterGuruAccessToken: ", accessTokenInstance.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
