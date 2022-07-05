//
//  Constants.swift
//  CryptoInsta
//
//  Created by Lev Baklanov on 01.06.2022.
//

import Foundation

struct Constants {
    
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
        static let Testnet = "0xe68b53F733DC34d2470F62F19558AB931EFECF71"
    }
    
    struct AccessTokenContract {
        static let Mainnet = ""
        static let Testnet = "0xCC542dE6962f13F7DA5F5e75F71097F714403dbC"
    }
    
    struct MinterContract {
        static let Mainnet = ""
        static let Testnet = "0x2484574280a261c21a29E428A0Dc438E5b593087"
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
