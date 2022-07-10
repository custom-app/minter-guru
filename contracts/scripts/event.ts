// eslint-disable-next-line node/no-missing-import,camelcase
import { MinterGuruToken__factory } from "../typechain";
import * as hre from "hardhat";
import { program } from "commander";

async function main() {
  program
    .option("-contract, --contract <string>")
    .option("-value, --value <number>")
    .option("-start, --start <number>")
    .option("-finish, --finish <number>")
    .option("-thresholds, --thresholds <string>")
    .option("-values, --values <string>");
  program.parse();
  const args = program.opts();
  const accounts = await hre.ethers.getSigners();
  const BN = hre.ethers.BigNumber;

  const multiplier = BN.from(10).pow(BN.from(18));
  const thresholds = args.thresholds
    .split(",")
    .map((t: any) => Number(t))
    .map((t: number) => BN.from(t));
  const values = args.values
    .split(",")
    .map((t: any) => Number(t))
    .map((t: number) => BN.from(t).mul(multiplier));
  const factory = new MinterGuruToken__factory(accounts[3]);
  const instance = factory.attach(args.contract);
  console.log(
    "creating event",
    BN.from(Number(args.value)).mul(multiplier),
    BN.from(Number(args.start)),
    BN.from(Number(args.finish)),
    thresholds,
    values
  );
  const tx = await instance
    .connect(accounts[3])
    .createEvent(
      BN.from(Number(args.value)).mul(multiplier),
      BN.from(Number(args.start)),
      BN.from(Number(args.finish)),
      thresholds,
      values
    );
  console.log(tx.hash);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
