import { expect } from "chai";
import { ethers } from "hardhat";
import { Signer, BigNumber as BN } from "ethers";
// eslint-disable-next-line camelcase,node/no-missing-import
import {
  InstaToken,
  // eslint-disable-next-line camelcase
  InstaToken__factory,
  // eslint-disable-next-line camelcase
  PrivateCollection__factory,
  CollectionsAccessToken,
  // eslint-disable-next-line camelcase
  CollectionsAccessToken__factory,
  PrivateCollection,
  // eslint-disable-next-line node/no-missing-import
} from "../typechain";

const genRanHex = (size: number) =>
  [...Array(size)]
    .map(() => Math.floor(Math.random() * 16).toString(16))
    .join("");

describe("Private collection", async () => {
  let accounts: Signer[];
  let accessTokenInstance: CollectionsAccessToken;
  let instaToken: InstaToken;

  before(async () => {
    accounts = await ethers.getSigners();

    const collectionFactory = new PrivateCollection__factory(accounts[0]);
    const privateCollection = await collectionFactory.deploy();

    const instaTokenFactory = new InstaToken__factory(accounts[0]);
    instaToken = await instaTokenFactory.deploy(
      BN.from(10000),
      BN.from(3000),
      BN.from(3000),
      BN.from(4000),
      await accounts[1].getAddress(),
      await accounts[2].getAddress(),
      await accounts[3].getAddress()
    );

    const accessTokenFactory = new CollectionsAccessToken__factory(accounts[0]);
    accessTokenInstance = await accessTokenFactory.deploy(
      "test",
      "test",
      instaToken.address,
      privateCollection.address,
      BN.from(100)
    );
  });

  it("transfer should be successful", async () => {
    await instaToken
      .connect(accounts[1])
      .transfer(await accounts[4].getAddress(), BN.from(100));
  });

  it("buy and mint should be successful", async () => {
    const salt = "0x" + genRanHex(64);
    const privateCollectionAddress =
      await accessTokenInstance.predictDeterministicAddress(salt);
    const purchaseTx = await accessTokenInstance.purchasePrivateCollection(
      salt,
      "tsst",
      "tost"
    );
    expect(purchaseTx).to.emit("ERC20", "Transfer").withArgs(
      await accounts[4].getAddress(), "0x", );
    const collectionFactory = new PrivateCollection__factory(accounts[0]);
    const privateCollection: PrivateCollection = collectionFactory.attach(
      privateCollectionAddress
    );

  });
});
