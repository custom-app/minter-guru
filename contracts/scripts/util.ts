import {
  // eslint-disable-next-line camelcase
  MinterGuruCollectionsAccessToken,
  // eslint-disable-next-line camelcase
  MinterGuruCollectionsAccessToken__factory,
  MinterGuruPrivateCollection,
  // eslint-disable-next-line camelcase
  MinterGuruPrivateCollection__factory,
  MinterGuruToken,
  // eslint-disable-next-line camelcase
  MinterGuruToken__factory,
  // eslint-disable-next-line node/no-missing-import,camelcase
} from "../typechain";
import { Signer, BigNumber as BN } from "ethers";

export async function createPrivateCollectionsAccessToken(
  account: Signer,
  tokenAddress: string,
  accessTokenContractMetaUri: string,
  collectionPrice: BN
): Promise<MinterGuruCollectionsAccessToken> {
  const factory = new MinterGuruPrivateCollection__factory(account);
  const impl: MinterGuruPrivateCollection = await factory.deploy();
  const accessTokenFactory = new MinterGuruCollectionsAccessToken__factory(
    account
  );
  return await accessTokenFactory.deploy(
    "MinterGuruAccessToken",
    "MIGUAT",
    accessTokenContractMetaUri,
    tokenAddress,
    impl.address,
    collectionPrice
  );
}

export async function createMinterGuruToken(
  accounts: Signer[],
  totalLimit: BN,
  liquidityAmount: BN,
  vestingAmount: BN,
  communityReward: BN
): Promise<string> {
  const factory = new MinterGuruToken__factory(accounts[0]);
  const instance: MinterGuruToken = await factory.deploy(
    totalLimit,
    liquidityAmount,
    vestingAmount,
    communityReward,
    await accounts[1].getAddress(),
    await accounts[2].getAddress(),
    await accounts[3].getAddress()
  );
  return instance.address;
}
