import { expect } from "chai";
import { ethers } from "hardhat";
import { BigNumber as BN, Signer } from "ethers";
// eslint-disable-next-line camelcase,node/no-missing-import
import {
  MinterGuruCollectionsAccessToken,
  // eslint-disable-next-line camelcase
  MinterGuruCollectionsAccessToken__factory,
  MinterGuruToken,
  // eslint-disable-next-line camelcase
  MinterGuruToken__factory,
  MinterGuruPrivateCollection,
  // eslint-disable-next-line camelcase
  MinterGuruPrivateCollection__factory,
  // eslint-disable-next-line node/no-missing-import
} from "../typechain";

const genRanHex = (size: number) =>
  [...Array(size)]
    .map(() => Math.floor(Math.random() * 16).toString(16))
    .join("");

describe("Private collection", async () => {
  let accounts: Signer[];
  let accessTokenInstance: MinterGuruCollectionsAccessToken;
  let instaToken: MinterGuruToken;
  let boughtCollection: MinterGuruPrivateCollection;

  before(async () => {
    accounts = await ethers.getSigners();

    const collectionFactory = new MinterGuruPrivateCollection__factory(
      accounts[0]
    );
    const privateCollection = await collectionFactory.deploy();

    const instaTokenFactory = new MinterGuruToken__factory(accounts[0]);
    instaToken = await instaTokenFactory.deploy(
      BN.from(10000),
      BN.from(3000),
      BN.from(3000),
      BN.from(4000),
      await accounts[1].getAddress(),
      await accounts[2].getAddress(),
      await accounts[3].getAddress()
    );

    const accessTokenFactory = new MinterGuruCollectionsAccessToken__factory(
      accounts[0]
    );
    accessTokenInstance = await accessTokenFactory.deploy(
      "test",
      "test",
      "",
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

  it("self collections should be empty before purchase", async () => {
    const collections = await accessTokenInstance
      .connect(accounts[4])
      .getSelfCollections(BN.from(0), BN.from(10));
    expect(collections).deep.eq([[], []]);
  });

  it("buy should be successful", async () => {
    await instaToken
      .connect(accounts[4])
      .approve(accessTokenInstance.address, BN.from(100));
    const salt = "0x" + genRanHex(64);
    const collectionFactory = new MinterGuruPrivateCollection__factory(
      accounts[0]
    );
    boughtCollection = collectionFactory.attach(
      await accessTokenInstance.predictDeterministicAddress(salt)
    );
    const purchaseTx = await accessTokenInstance
      .connect(accounts[4])
      .purchasePrivateCollection(salt, "tsst", "tost", "", "", "0xaa");
    expect(purchaseTx)
      .to.emit(instaToken, "Transfer")
      .withArgs(
        await accounts[4].getAddress(),
        "0x0000000000000000000000000000000000000000",
        BN.from(100)
      );
    expect(purchaseTx)
      .to.emit(accessTokenInstance, "CollectionCreated")
      .withArgs(boughtCollection.address, BN.from(0));
  });

  it("mint batch should be successful", async () => {
    const metaUris: string[] = [];
    const data = [];
    for (let i = 0; i < 20; i++) {
      metaUris.push("");
      data.push("0x");
    }
    await boughtCollection
      .connect(accounts[4])
      .mintBatch(await accounts[4].getAddress(), BN.from(20), metaUris, data);
  });

  it("transfer should be successful", async () => {
    await accessTokenInstance
      .connect(accounts[4])
      .transferFrom(
        await accounts[4].getAddress(),
        await accounts[0].getAddress(),
        BN.from(0)
      );
  });
});
