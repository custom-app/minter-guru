// eslint-disable-next-line node/no-missing-import,camelcase
import { MinterGuruCollectionsAccessToken__factory } from "../typechain";
import * as hre from "hardhat";
import { program } from "commander";

async function main() {
  program
    .option("-token, --token <string>")
    .option("-to, --to <string>")
    .option("-id, --id <number>");
  program.parse();

  const args = program.opts();
  const accounts = await hre.ethers.getSigners();
  const factory = new MinterGuruCollectionsAccessToken__factory(accounts[0]);
  const instance = factory.attach(args.token);
  const tx = await instance
    .connect(accounts[4])
    .transferFrom(
      await accounts[4].getAddress(),
      args.to,
      hre.ethers.BigNumber.from(Number(args.id))
    );
  console.log("transfer access token txid: ", tx.hash);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
