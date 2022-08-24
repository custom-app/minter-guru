import {
  // eslint-disable-next-line camelcase
  MinterGuruCollectionsAccessToken__factory,
  MinterGuruPrivateCollection,
  // eslint-disable-next-line camelcase
  MinterGuruPrivateCollection__factory,
  // eslint-disable-next-line node/no-missing-import
} from "../typechain";
import * as hre from "hardhat";
import { program } from "commander";

async function main() {
  program.option("-token, --token <string>");
  program.parse();

  const args = program.opts();
  const accounts = await hre.ethers.getSigners();
  const factory = new MinterGuruCollectionsAccessToken__factory(accounts[0]);
  const instance = factory.attach(args.token);

  const collectionFactory = new MinterGuruPrivateCollection__factory(
    accounts[0]
  );
  const collectionImpl: MinterGuruPrivateCollection =
    await collectionFactory.deploy();

  const tx = await instance
    .connect(accounts[0])
    .setImplementation(collectionImpl.address);
  console.log("set implementation txid: ", tx.hash);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
