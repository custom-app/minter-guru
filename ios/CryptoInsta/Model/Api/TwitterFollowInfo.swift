//
//  TwitterFollowInfo.swift
//  CryptoInsta
//
//  Created by Lev Baklanov on 27.07.2022.
//

import Foundation

struct TwitterFollowInfo: Codable {
    let open: Bool
    let limit: Int
    let spent: Int
    let value: String
}

struct TwitterFollowReward: Codable {
    let createdAt: Int
    let transaction: Transaction
    
    struct Transaction: Codable {
        let id: String
    }
}
