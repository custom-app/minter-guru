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
        static let Testnet = "0x2DCf712Fcba49b834Ad42615F28330E09047b69c"
    }
    
    static var routerAddress: String {
        if Config.TESTING {
            return RouterContract.Testnet
        } else {
            return RouterContract.Mainnet
        }
    }
}
