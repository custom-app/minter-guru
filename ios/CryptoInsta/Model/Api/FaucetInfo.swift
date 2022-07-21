//
//  FaucetInfo.swift
//  CryptoInsta
//
//  Created by Lev Baklanov on 21.07.2022.
//

import Foundation

struct FaucetInfo: Codable {
    let open: Bool
    let value: String
    let limit: Int
    let spent: Int
}
