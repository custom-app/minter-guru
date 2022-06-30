import { expect } from "chai";
import { ethers } from "hardhat";
import { Signer, BigNumber as BN } from "ethers";
// eslint-disable-next-line camelcase,node/no-missing-import
import {
  PublicCollection,
  // eslint-disable-next-line camelcase
  PublicCollection__factory,
  PublicCollectionsRouter,
  // eslint-disable-next-line camelcase
  PublicCollectionsRouter__factory,
  // eslint-disable-next-line node/no-missing-import
} from "../typechain";

const genRanHex = (size: number) =>
  [...Array(size)]
    .map(() => Math.floor(Math.random() * 16).toString(16))
    .join("");

const checkCollectionsList = async (
  router: PublicCollectionsRouter,
  account: Signer,
  page: number,
  size: number,
  expectedCollections: any[],
  expectedTokens: any[],
  expectedTotal: number
) => {
  const [collections, tokens, total] = await router
    .connect(account)
    .getSelfPublicTokens(BN.from(page), BN.from(size));
  expect(collections).deep.eq(expectedCollections);
  expect(tokens).deep.eq(expectedTokens);
  expect(total).eq(BN.from(expectedTotal));
};

describe("PublicCollectionRouter single version", async () => {
  let accounts: Signer[];
  let collection: PublicCollection;
  let router: PublicCollectionsRouter;

  before(async () => {
    accounts = await ethers.getSigners();
    const factory = new PublicCollection__factory(accounts[0]);
    const impl: PublicCollection = await factory.deploy();

    const routerFactory = new PublicCollectionsRouter__factory(accounts[0]);
    router = await routerFactory.deploy(impl.address);
  });

  it("create clone should be successful", async () => {
    const salt = "0x" + genRanHex(64);
    const collectionAddress: string = await router
      .connect(accounts[0])
      .predictDeterministicAddress(salt);
    const factory = new PublicCollection__factory(accounts[0]);
    const cloneTx = await router
      .connect(accounts[0])
      .createCollectionClone(salt, "test", "TEST");
    expect(cloneTx)
      .to.emit("PublicCollectionsRouter", "CollectionCreated")
      .withArgs(collectionAddress, "0");
    collection = factory.attach(collectionAddress);
  });

  it("id to mint should equal to 0", async () => {
    expect(await router.idToMint(BN.from(0))).eq(BN.from(0));
  });

  it("id to mint should failed if version doesn't exist", async () => {
    expect(router.idToMint(BN.from(1))).revertedWith(
      "PublicCollectionsRouter: unknown version"
    );
  });

  it("tokens list should be empty", async () => {
    await checkCollectionsList(router, accounts[1], 0, 1, [], [], 0);
  });

  it("mint should be successful", async () => {
    const tx = await router
      .connect(accounts[1])
      .mint(BN.from(0), BN.from(0), "kek", "0x10");
    expect(tx)
      .to.emit("PublicCollectionsRouter", "PublicMint")
      .withArgs(collection.address, await accounts[1].getAddress(), BN.from(0));
  });

  it("token count should increased", async () => {
    expect(await collection.tokensCount()).eq(BN.from(1));
  });

  it("id to mint should increased", async () => {
    expect(await router.idToMint(BN.from(0))).eq(BN.from(1));
  });

  it("token list after mint", async () => {
    await checkCollectionsList(
      router,
      accounts[1],
      0,
      1,
      [[collection.address, BN.from(0)]],
      [[[BN.from(0), "kek", "0x10"]]],
      1
    );
    const [collections, tokens, total] = await router
      .connect(accounts[1])
      .getSelfPublicTokens(BN.from(0), BN.from(1));
    expect(collections).deep.eq([[collection.address, BN.from(0)]]);
    expect(tokens).deep.eq([[[BN.from(0), "kek", "0x10"]]]);
    expect(total).eq(BN.from(1));
  });

  it("second mint should be successful", async () => {
    const tx = await router
      .connect(accounts[1])
      .mint(BN.from(0), BN.from(1), "kekes", "0x20");
    expect(tx)
      .to.emit("PublicCollectionsRouter", "PublicMint")
      .withArgs(collection.address, await accounts[1].getAddress(), BN.from(0));
  });

  it("token list after two mint", async () => {
    await checkCollectionsList(
      router,
      accounts[1],
      0,
      20,
      [[collection.address, BN.from(0)]],
      [
        [
          [BN.from(0), "kek", "0x10"],
          [BN.from(1), "kekes", "0x20"],
        ],
      ],
      2
    );
    await checkCollectionsList(
      router,
      accounts[1],
      1,
      1,
      [[collection.address, BN.from(0)]],
      [[[BN.from(1), "kekes", "0x20"]]],
      2
    );
  });
});

describe("PublicCollectionRouter multiple versions", async () => {
  let accounts: Signer[];
  let collectionV1: PublicCollection;
  let collectionV2: PublicCollection;
  let router: PublicCollectionsRouter;

  before(async () => {
    accounts = await ethers.getSigners();
    const factory = new PublicCollection__factory(accounts[0]);
    const impl: PublicCollection = await factory.deploy();

    const routerFactory = new PublicCollectionsRouter__factory(accounts[0]);
    router = await routerFactory.deploy(impl.address);
  });

  it("create clone should be successful", async () => {
    const salt = "0x" + genRanHex(64);
    const collectionAddress: string = await router
      .connect(accounts[0])
      .predictDeterministicAddress(salt);
    const factory = new PublicCollection__factory(accounts[0]);
    await router
      .connect(accounts[0])
      .createCollectionClone(salt, "test", "TEST");
    collectionV1 = factory.attach(collectionAddress);
  });

  it("set implementation and clone should be successful", async () => {
    const factory = new PublicCollection__factory(accounts[0]);
    const implV2: PublicCollection = await factory.deploy();
    await router.setImplementation(implV2.address);
    const salt = "0x" + genRanHex(64);
    const collectionAddress: string = await router
      .connect(accounts[0])
      .predictDeterministicAddress(salt);
    await router
      .connect(accounts[0])
      .createCollectionClone(salt, "test", "TEST");
    collectionV2 = factory.attach(collectionAddress);
  });

  it("mint should be successful", async () => {
    const txV1 = await router
      .connect(accounts[1])
      .mint(BN.from(0), BN.from(0), "kek", "0x10");
    expect(txV1)
      .to.emit("PublicCollectionsRouter", "PublicMint")
      .withArgs(
        collectionV1.address,
        await accounts[1].getAddress(),
        BN.from(0)
      );

    const txV2 = await router
      .connect(accounts[1])
      .mint(BN.from(1), BN.from(0), "kekes", "0x20");
    expect(txV2)
      .to.emit("PublicCollectionsRouter", "PublicMint")
      .withArgs(
        collectionV2.address,
        await accounts[1].getAddress(),
        BN.from(0)
      );
  });

  it("full token list should be correct", async () => {
    await checkCollectionsList(
      router,
      accounts[1],
      0,
      20,
      [
        [collectionV1.address, BN.from(0)],
        [collectionV2.address, BN.from(1)],
      ],
      [[[BN.from(0), "kek", "0x10"]], [[BN.from(0), "kekes", "0x20"]]],
      2
    );
  });

  it("two lists should be correct", async () => {
    await checkCollectionsList(
      router,
      accounts[1],
      0,
      1,
      [[collectionV1.address, BN.from(0)]],
      [[[BN.from(0), "kek", "0x10"]]],
      2
    );
    await checkCollectionsList(
      router,
      accounts[1],
      1,
      1,
      [[collectionV2.address, BN.from(1)]],
      [[[BN.from(0), "kekes", "0x20"]]],
      2
    );
  });
});
