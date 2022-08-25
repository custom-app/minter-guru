//
//  Constants.swift
//  CryptoInsta
//
//  Created by Lev Baklanov on 01.06.2022.
//

import Foundation

struct Constants {
    
    static let ADDRESS_LEN = 42
    
    static let twitterCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_")
    static let twitterLink = "https://twitter.com/"
    static let sessionKey = "session_key"
    static let currentVersion = 0
    static let ipfsMinterImage = "ipfs://QmabMpksqkBnD48a4sdSNj5Y3uEG4hTzJxri7jE88vTz2g"
    static let ipfsAccessTokenMeta = "ipfs://bafkreigvvqwpop4aeucnjdw6ozjecinuwujka7cjzj7cd323pmsek7mvxu"
    static let minterTwitterLink = "https://twitter.com/MinterGuru"
    static let minterHashtag = "#MinterGuru"
    
    static var contractsConfig: ContractsConfig? = nil
    
    struct Bridges {
        static let Gnosis = "https://safe-walletconnect.gnosis.io/"
        static let Wc = "https://bridge.walletconnect.org"
    }
    
    struct ChainId {
        static let Polygon = 137
        static let PolygonTestnet = 80001
    }
    
    static var requiredChainId: Int {
        if Config.TESTING {
            return ChainId.PolygonTestnet
        } else {
            return ChainId.Polygon
        }
    }
    
    struct Filebase {
        static let endpoint = "s3.filebase.com"
    }
    
    struct RouterContract {
        static let Mainnet = "0xe760Cf4Ef449139541d2674aCAAE22f906775baC"
        static let Testnet = "0x551750045d9DeC7Fb5023E96c9543492395af946"
    }
    
    struct AccessTokenContract {
        static let Mainnet = "0x8dDAC2F23730E168C3684C2567338b6697B291e0"
        static let Testnet = "0xe8e273aA17227972709B9FE389871C74e9f8C382"
    }
    
    struct MinterContract {
        static let Mainnet = "0x580aeE9658cC4382cbFbCC32977379a3f4695D25"
        static let Testnet = "0x3962276a988347A1DD8EBEa5f0ea44798d09803D"
    }
    
    struct BackendEndpoint {
        static let Prod = "https://api.minter.guru"
        static let Dev = "https://api-dev.minter.guru"
    }
    
    static var routerAddress: String {
        if let contractsConfig = contractsConfig {
            return contractsConfig.router
        }
        if Config.TESTING {
            return RouterContract.Testnet
        } else {
            return RouterContract.Mainnet
        }
    }
    
    static var accessTokenAddress: String {
        if let contractsConfig = contractsConfig {
            return contractsConfig.accessToken
        }
        if Config.TESTING {
            return AccessTokenContract.Testnet
        } else {
            return AccessTokenContract.Mainnet
        }
    }
    
    static var minterAddress: String {
        if let contractsConfig = contractsConfig {
            return contractsConfig.miguToken
        }
        if Config.TESTING {
            return MinterContract.Testnet
        } else {
            return MinterContract.Mainnet
        }
    }
    
    static var backendUrl: String {
        if Config.TESTING {
            return BackendEndpoint.Dev
        } else {
            return BackendEndpoint.Prod
        }
    }
}
