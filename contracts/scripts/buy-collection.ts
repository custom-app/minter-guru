// eslint-disable-next-line node/no-missing-import,camelcase
import { MinterGuruCollectionsAccessToken__factory } from "../typechain";
import * as hre from "hardhat";
import { program } from "commander";

const genRanHex = (size: number) =>
  [...Array(size)]
    .map(() => Math.floor(Math.random() * 16).toString(16))
    .join("");

async function main() {
  program.option("-token, --token <string>");
  program.parse();

  const args = program.opts();
  const accounts = await hre.ethers.getSigners();
  const factory = new MinterGuruCollectionsAccessToken__factory(accounts[0]);
  const instance = factory.attach(args.token);
  const salt = genRanHex(64);
  console.log(salt);
  const tx = await instance
    .connect(accounts[4])
    .purchasePrivateCollection(
      "0x" + salt,
      "Sesh",
      "SHS",
      "ipfs://bafkreibba2qhrnyqxbs4klnvijhoa3c77hhhrglo54afuvb4likcs2sfi4",
      "",
      "0x"
    );
  console.log("purchase txid: ", tx.hash);
  const predictedAddress = await instance
    .connect(accounts[4])
    .predictDeterministicAddress("0x" + salt);
  console.log("private collection address: ", predictedAddress);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
