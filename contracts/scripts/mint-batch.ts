// eslint-disable-next-line node/no-missing-import,camelcase
import { MinterGuruPrivateCollection__factory } from "../typechain";
import * as hre from "hardhat";
import { program } from "commander";

async function main() {
  program.option("-collection, --collection <string>");
  program.parse();

  const args = program.opts();
  const accounts = await hre.ethers.getSigners();
  const factory = new MinterGuruPrivateCollection__factory(accounts[0]);
  const instance = factory.attach(args.collection);
  const count = 20;
  const metaUris = [];
  const data = [];
  for (let i = 0; i < count; i++) {
    metaUris.push(
      "ipfs://bafkreifscmrdikpqxyqpi66nk22gyxyki4tgj23vszv25724fmqr4ok7eu"
    );
    data.push("0x");
  }
  const tx = await instance
    .connect(accounts[4])
    .mintBatch(await accounts[4].getAddress(), count, metaUris, data);
  console.log("mint txid: ", tx.hash);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
