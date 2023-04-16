//
//  RewardInfo.swift
//  CryptoInsta
//
//  Created by Lev Baklanov on 19.07.2022.
//

import Foundation

struct RewardInfo: Codable {
    let id: Int
    let createdAt: Int
    let username: String
    let url: String
    let transaction: Transaction?
}

struct Transaction: Codable {
    let id: String?
}
