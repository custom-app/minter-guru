import {
  // eslint-disable-next-line camelcase
  MinterGuruCollectionsAccessToken,
  // eslint-disable-next-line camelcase
  MinterGuruCollectionsAccessToken__factory,
  MinterGuruPrivateCollection,
  // eslint-disable-next-line camelcase
  MinterGuruPrivateCollection__factory,
  // eslint-disable-next-line node/no-missing-import,camelcase
} from "../typechain";
import { Signer } from "ethers";
import { BigNumber as BN } from "@ethersproject/bignumber/lib/bignumber";

export async function createPrivateCollectionsAccessToken(
  account: Signer,
  tokenAddress: string
): Promise<MinterGuruCollectionsAccessToken> {
  const factory = new MinterGuruPrivateCollection__factory(account);
  const impl: MinterGuruPrivateCollection = await factory.deploy();
  const accessTokenFactory = new MinterGuruCollectionsAccessToken__factory(
    account
  );
  const multiplier = BN.from(10).pow(BN.from(18));
  return await accessTokenFactory.deploy(
    "MinterGuruAccessToken",
    "MIGUAT",
    tokenAddress,
    impl.address,
    BN.from(1).mul(multiplier)
  );
}
