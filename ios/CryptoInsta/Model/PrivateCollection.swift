//
//  PrivateCollectionData.swift
//  CryptoInsta
//
//  Created by Lev Baklanov on 11.07.2022.
//

import Foundation

struct PrivateCollection: Hashable {
    
    let address: String
    let tokensCount: Int
    let data: PrivateCollectionData
    
    static func == (lhs: PrivateCollection, rhs: PrivateCollection) -> Bool {
        lhs.address == rhs.address
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(address)
    }
}
