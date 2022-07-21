//
//  ApiRoutes.swift
//  CryptoInsta
//
//  Created by Lev Baklanov on 19.07.2022.
//

import Foundation

enum ApiRoute: String {
    
    case callFaucet = "/faucet/by_address"
    case checkFaucet = "/faucet/has"
    case faucetInfo = "/faucet/config"
    
    case twitterInfo = "/twitter/config"
    case applyForTwitter = "/twitter/by_address"
    case twitterRewards = "/twitter/get_records/by_address"
}
