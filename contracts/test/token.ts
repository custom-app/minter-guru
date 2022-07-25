import { expect } from "chai";
import { ethers } from "hardhat";
import { BigNumber as BN, Signer } from "ethers";
// eslint-disable-next-line camelcase,node/no-missing-import
import {
  MinterGuruToken,
  // eslint-disable-next-line camelcase
  MinterGuruToken__factory,
  // eslint-disable-next-line node/no-missing-import
} from "../typechain";

describe("Token gaming event", async () => {
  let accounts: Signer[];
  let tokenInstance: MinterGuruToken;
  let start: number;

  before(async () => {
    start = Math.round(Date.now() / 1000) + 10000;
    await ethers.provider.send("evm_mine", [start]);
    accounts = await ethers.getSigners();

    const tokenFactory = new MinterGuruToken__factory(accounts[0]);
    tokenInstance = await tokenFactory.deploy(
      BN.from(10000),
      BN.from(3000),
      BN.from(3000),
      BN.from(4000),
      await accounts[1].getAddress(),
      await accounts[2].getAddress(),
      await accounts[3].getAddress()
    );
  });

  it("start event should be successful", async () => {
    await ethers.provider.send("evm_mine", [start + 10]);
    await tokenInstance
      .connect(accounts[3])
      .createEvent(
        BN.from(10),
        BN.from(start + 11),
        BN.from(Math.round(start + 11 + 10)),
        [BN.from(5000), BN.from(20000)],
        [BN.from(5), BN.from(2), BN.from(1)]
      );
  });

  it("get event should return correct values", async () => {
    const ev = await tokenInstance.currentEvents(BN.from(0));
    expect(ev).deep.eq([
      BN.from(0),
      BN.from(10),
      BN.from(start + 11),
      BN.from(start + 11 + 10),
      BN.from(0),
    ]);
  });

  it("can mint should return true", async () => {
    const canMint = await tokenInstance.canMint(BN.from(0), BN.from(3));
    expect(canMint).eq(BN.from(3));
  });

  it("mint middle value", async () => {
    const tx = await tokenInstance
      .connect(accounts[3])
      .mintCommunityReward(BN.from(0), await accounts[0].getAddress());
    expect(tx)
      .to.emit("ERC20", "Transfer")
      .withArgs(
        "0x0000000000000000000000000000000000000000",
        await accounts[0].getAddress(),
        BN.from(2)
      );
  });

  it("mint highest value", async () => {
    await ethers.provider.send("evm_mine", [start + 15]);
    const tx = await tokenInstance
      .connect(accounts[3])
      .mintCommunityReward(BN.from(0), await accounts[0].getAddress());
    expect(tx)
      .to.emit("ERC20", "Transfer")
      .withArgs(
        "0x0000000000000000000000000000000000000000",
        await accounts[0].getAddress(),
        BN.from(5)
      );
  });

  it("mint lowest value", async () => {
    const tx = await tokenInstance
      .connect(accounts[3])
      .mintCommunityReward(BN.from(0), await accounts[0].getAddress());
    expect(tx)
      .to.emit("ERC20", "Transfer")
      .withArgs(
        "0x0000000000000000000000000000000000000000",
        await accounts[0].getAddress(),
        BN.from(1)
      );
  });

  it("can mint not all", async () => {
    const canMint = await tokenInstance.canMint(BN.from(0), BN.from(3));
    expect(canMint).eq(BN.from(1));
  });

  it("mint failed", async () => {
    const tx = tokenInstance
      .connect(accounts[3])
      .mintCommunityRewardForMultiple(BN.from(0), [
        await accounts[0].getAddress(),
        await accounts[0].getAddress(),
      ]);
    expect(tx).revertedWith("MinterGuruToken: supply finished");
  });

  it("mint last token", async () => {
    const tx = await tokenInstance
      .connect(accounts[3])
      .mintCommunityRewardForMultiple(BN.from(0), [
        await accounts[0].getAddress(),
      ]);
    expect(tx)
      .to.emit("ERC20", "Transfer")
      .withArgs(
        "0x0000000000000000000000000000000000000000",
        await accounts[0].getAddress(),
        BN.from(2)
      );
    expect(tx)
      .to.emit("MinterGuruToken", "CommunityEventFinished")
      .withArgs(BN.from(0));
  });
});
