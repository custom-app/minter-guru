import { expect } from "chai";
import { ethers } from "hardhat";
import { Signer, BigNumber as BN } from "ethers";
// eslint-disable-next-line camelcase,node/no-missing-import
import {
  MinterGuruPublicCollection,
  // eslint-disable-next-line camelcase
  MinterGuruPublicCollection__factory,
  MinterGuruPublicCollectionsRouter,
  // eslint-disable-next-line camelcase
  MinterGuruPublicCollectionsRouter__factory,
  // eslint-disable-next-line node/no-missing-import
} from "../typechain";
import "@nomicfoundation/hardhat-chai-matchers";

const genRanHex = (size: number) =>
  [...Array(size)]
    .map(() => Math.floor(Math.random() * 16).toString(16))
    .join("");

const checkCollectionsList = async (
  router: MinterGuruPublicCollectionsRouter,
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
  let collection: MinterGuruPublicCollection;
  let router: MinterGuruPublicCollectionsRouter;

  before(async () => {
    accounts = await ethers.getSigners();
    const factory = new MinterGuruPublicCollection__factory(accounts[0]);
    const impl: MinterGuruPublicCollection = await factory.deploy();

    const routerFactory = new MinterGuruPublicCollectionsRouter__factory(
      accounts[0]
    );
    router = await routerFactory.deploy(impl.address);
  });

  it("create clone should be successful", async () => {
    const salt = "0x" + genRanHex(64);
    const collectionAddress: string = await router
      .connect(accounts[0])
      .predictDeterministicAddress(salt);
    const factory = new MinterGuruPublicCollection__factory(accounts[0]);
    const cloneTx = await router
      .connect(accounts[0])
      .createCollectionClone(salt, "test", "TEST", "");
    expect(cloneTx)
      .to.emit(router, "CollectionCreated")
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
      .to.emit(router, "PublicMint")
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
      .to.emit(router, "PublicMint")
      .withArgs(collection.address, await accounts[1].getAddress(), BN.from(1));
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

  it("third mint should be successful", async () => {
    const tx = router
      .connect(accounts[1])
      .mint(BN.from(0), BN.from(2), "kekes", "0x30");
    await expect(tx)
      .to.emit(router, "PublicMint")
      .withArgs(collection.address, await accounts[1].getAddress(), BN.from(2));
  });

  it("get not from begin", async () => {
    await checkCollectionsList(
      router,
      accounts[1],
      1,
      2,
      [[collection.address, BN.from(0)]],
      [[[BN.from(2), "kekes", "0x30"]]],
      3
    );
  });
});

describe("PublicCollectionRouter multiple versions", async () => {
  let accounts: Signer[];
  let collectionV1: MinterGuruPublicCollection;
  let collectionV2: MinterGuruPublicCollection;
  let router: MinterGuruPublicCollectionsRouter;

  before(async () => {
    accounts = await ethers.getSigners();
    const factory = new MinterGuruPublicCollection__factory(accounts[0]);
    const impl: MinterGuruPublicCollection = await factory.deploy();

    const routerFactory = new MinterGuruPublicCollectionsRouter__factory(
      accounts[0]
    );
    router = await routerFactory.deploy(impl.address);
  });

  it("create clone should be successful", async () => {
    const salt = "0x" + genRanHex(64);
    const collectionAddress: string = await router
      .connect(accounts[0])
      .predictDeterministicAddress(salt);
    const factory = new MinterGuruPublicCollection__factory(accounts[0]);
    await router
      .connect(accounts[0])
      .createCollectionClone(salt, "test", "TEST", "");
    collectionV1 = factory.attach(collectionAddress);
  });

  it("set implementation and clone should be successful", async () => {
    const factory = new MinterGuruPublicCollection__factory(accounts[0]);
    const implV2: MinterGuruPublicCollection = await factory.deploy();
    await router.setImplementation(implV2.address);
    const salt = "0x" + genRanHex(64);
    const collectionAddress: string = await router
      .connect(accounts[0])
      .predictDeterministicAddress(salt);
    await router
      .connect(accounts[0])
      .createCollectionClone(salt, "test", "TEST", "");
    collectionV2 = factory.attach(collectionAddress);
  });

  it("mint wihtout id should be successful", async () => {
    const txV1 = await router
      .connect(accounts[1])
      .mintWithoutId(BN.from(0), "kek", "0x10");
    expect(txV1)
      .to.emit(router, "PublicMint")
      .withArgs(
        collectionV1.address,
        await accounts[1].getAddress(),
        BN.from(0)
      );

    const txV2 = await router
      .connect(accounts[1])
      .mint(BN.from(1), BN.from(0), "kekes", "0x20");
    expect(txV2)
      .to.emit(router, "PublicMint")
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
