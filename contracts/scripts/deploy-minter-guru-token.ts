import * as hre from "hardhat";
// eslint-disable-next-line node/no-missing-import
import { createMinterGuruToken } from "./util";
import { Signer } from "ethers";

async function main() {
  const accounts: Signer[] = await hre.ethers.getSigners();
  const tokenAddress = await createMinterGuruToken(accounts);
  console.log("MinterGuruToken: ", tokenAddress);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
