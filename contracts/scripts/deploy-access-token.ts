import * as hre from "hardhat";
import { program } from "commander";
// eslint-disable-next-line node/no-missing-import
import { createPrivateCollectionsAccessToken } from "./util";
import { BigNumber as BN } from "ethers";

async function main() {
  program.option("-token, --token <string>");
  program.parse();

  const args = program.opts();
  const accounts = await hre.ethers.getSigners();
  const multiplier = BN.from(10).pow(BN.from(18));
  const accessTokenInstance = await createPrivateCollectionsAccessToken(
    accounts[0],
    args.token,
    "ipfs://bafkreicyphjyqqlxjzqlllwnxth3zqdoj3mkteeia46iyueuolgyzjzagm",
    BN.from(1).mul(multiplier)
  );
  console.log("MinterGuruAccessToken: ", accessTokenInstance.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
