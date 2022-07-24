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
  let eventStart: number;

  before(async () => {
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
    eventStart = Math.round(Date.now() / 1000);
    await tokenInstance
      .connect(accounts[3])
      .createEvent(
        BN.from(300),
        BN.from(eventStart),
        BN.from(Math.round(eventStart + 3600)),
        [BN.from(5000), BN.from(20000)],
        [BN.from(1), BN.from(2), BN.from(3)]
      );
  });

  it("get event should return correct values", async () => {
    const ev = await tokenInstance.currentEvents(BN.from(0));
    expect(ev).deep.eq([
      BN.from(0),
      BN.from(300),
      BN.from(eventStart),
      BN.from(eventStart + 3600),
      BN.from(0),
    ]);
  });

  it("can mint should return true", async () => {
    const canMint = await tokenInstance.canMint(BN.from(0), BN.from(3));
    expect(canMint).eq(BN.from(3));
  });
});
