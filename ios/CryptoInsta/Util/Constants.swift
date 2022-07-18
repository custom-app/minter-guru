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
        static let Testnet = "0x86F246ed3ff1A5D1e2752A4957e3047fc6CFD4b3"
    }
    
    struct AccessTokenContract {
        static let Mainnet = ""
        static let Testnet = "0x49d67D7D4a52D05129a77d650BCb4c0F55efc892"
    }
    
    struct MinterContract {
        static let Mainnet = ""
        static let Testnet = "0xbE4e7319234bF56c18dE2CEa057c3dB330A2b76C"
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
}
