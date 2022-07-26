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
    "ipfs://bafkreibba2qhrnyqxbs4klnvijhoa3c77hhhrglo54afuvb4likcs2sfi4",
    tokenAddress,
    impl.address,
    BN.from(1).mul(multiplier)
  );
}

export async function createMinterGuruToken(
  accounts: Signer[]
): Promise<string> {
  const factory = new MinterGuruToken__factory(accounts[0]);
  const multiplier = BN.from(10).pow(BN.from(18));
  const instance: MinterGuruToken = await factory.deploy(
    BN.from(100000).mul(multiplier),
    BN.from(50000).mul(multiplier),
    BN.from(20000).mul(multiplier),
    BN.from(30000).mul(multiplier),
    await accounts[1].getAddress(),
    await accounts[2].getAddress(),
    await accounts[3].getAddress()
  );
  return instance.address;
}
