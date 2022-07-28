//
//  PublicCollectionData.swift
//  CryptoInsta
//
//  Created by Lev Baklanov on 22.06.2022.
//

import Foundation

struct PublicCollection: Equatable {
    let address: String
    let version: Int
    
    static func == (lhs: PublicCollection, rhs: PublicCollection) -> Bool {
        return lhs.address == rhs.address &&
        lhs.version == rhs.version
    }
}
