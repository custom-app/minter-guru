// eslint-disable-next-line node/no-missing-import,camelcase
import { ERC20__factory } from "../typechain";
import * as hre from "hardhat";
import { program } from "commander";

async function main() {
  program
    .option("-token, --token <string>")
    .option("-access, --access <string>")
    .option("-value, --value <number>");
  program.parse();

  const args = program.opts();
  const accounts = await hre.ethers.getSigners();
  const factory = new ERC20__factory(accounts[0]);
  const instance = factory.attach(args.token);
  const value = Number(args.value);
  const multiplier = hre.ethers.BigNumber.from(10).pow(
    hre.ethers.BigNumber.from(18)
  );
  const tx = await instance
    .connect(accounts[4])
    .approve(args.access, hre.ethers.BigNumber.from(value).mul(multiplier));
  console.log("approve txid: ", tx.hash);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
