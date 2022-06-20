// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers } from "hardhat";
import { Signer } from "ethers";
import {
  PublicCollection,
  // eslint-disable-next-line camelcase
  PublicCollection__factory,
  PublicCollectionsRouter,
  // eslint-disable-next-line camelcase
  PublicCollectionsRouter__factory,
  // eslint-disable-next-line node/no-missing-import
} from "../typechain";

async function main() {
  const accounts: Signer[] = await ethers.getSigners();
  const factory = new PublicCollection__factory(accounts[0]);
  const impl: PublicCollection = await factory.deploy();

  const routerFactory = new PublicCollectionsRouter__factory(accounts[0]);
  const router: PublicCollectionsRouter = await routerFactory.deploy(
    impl.address
  );
  console.log(router.address);

  const genRanHex = (size: number) =>
    [...Array(size)]
      .map(() => Math.floor(Math.random() * 16).toString(16))
      .join("");
  await router.createCollectionClone("0x" + genRanHex(64), "test", "TEST");
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
