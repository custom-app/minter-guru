import * as hre from "hardhat";
// eslint-disable-next-line node/no-missing-import
import { createMinterGuruToken } from "./util";
import { Signer, BigNumber as BN } from "ethers";

async function main() {
  const accounts: Signer[] = await hre.ethers.getSigners();
  const multiplier = BN.from(10).pow(BN.from(18));
  const tokenAddress = await createMinterGuruToken(
    accounts,
    BN.from(100000).mul(multiplier),
    BN.from(50000).mul(multiplier),
    BN.from(20000).mul(multiplier),
    BN.from(30000).mul(multiplier)
  );
  console.log("MinterGuruToken: ", tokenAddress);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
