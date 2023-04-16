//
//  TwitterInfo.swift
//  CryptoInsta
//
//  Created by Lev Baklanov on 21.07.2022.
//

import Foundation

struct TwitterInfo: Codable {
    let open: Bool
    let limit: Int
    let spent: Int
    let personalLimit: Int
    let personalTotalLimit: Int
    let value: String
}
