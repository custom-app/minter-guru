import * as hre from "hardhat";
import { program } from "commander";
// eslint-disable-next-line node/no-missing-import
import { createPrivateCollectionsAccessToken } from "./util";

async function main() {
  program.option("-token, --token <string>");
  program.parse();

  const args = program.opts();
  const accounts = await hre.ethers.getSigners();
  const accessTokenInstance = await createPrivateCollectionsAccessToken(
    accounts[0],
    args.token
  );
  console.log("MinterGuruAccessToken: ", accessTokenInstance.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
