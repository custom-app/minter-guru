//
//  Constants.swift
//  CryptoInsta
//
//  Created by Lev Baklanov on 01.06.2022.
//

import Foundation

struct Constants {
    
    static let twitterCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_")
    static let twitterLink = "https://twitter.com/"
    static let sessionKey = "session_key"
    static let currentVersion = 0
    static let ipfsMinterImage = "ipfs://QmcENYH7SZhGi1Qu4GwRfBvvxnXh12nLmntvg8votDrka3"
    static let minterTwitterLink = "https://twitter.com/baklanov_dev"
    
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
        static let Mainnet = ""
        static let Testnet = "0x551750045d9DeC7Fb5023E96c9543492395af946"
    }
    
    struct AccessTokenContract {
        static let Mainnet = ""
        static let Testnet = "0xe8e273aA17227972709B9FE389871C74e9f8C382"
    }
    
    struct MinterContract {
        static let Mainnet = ""
        static let Testnet = "0x3962276a988347A1DD8EBEa5f0ea44798d09803D"
    }
    
    struct BackendEndpoint {
        static let Prod = ""
        static let Dev = "https://api-dev.minter.guru"
    }
    
    static var routerAddress: String {
        if Config.TESTING {
            return RouterContract.Testnet
        } else {
            return RouterContract.Mainnet
        }
    }
    
    static var accessTokenAddress: String {
        if Config.TESTING {
            return AccessTokenContract.Testnet
        } else {
            return AccessTokenContract.Mainnet
        }
    }
    
    static var minterAddress: String {
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
