//
//  NftData.swift
//  CryptoInsta
//
//  Created by Lev Baklanov on 22.06.2022.
//

import Foundation

struct NftData: Codable {
    let name: String
    let createDate: Int64
    let filebaseName: String?
}
