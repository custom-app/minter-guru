//
//  NftObject.swift
//  CryptoInsta
//
//  Created by Lev Baklanov on 04.06.2022.
//

import Foundation
import UIKit

struct Nft: Identifiable, Equatable {
    let id = UUID()
    let tokenId: Int
    let metaUrl: String
    let contractAddress: String
    let data: NftData
    var isPublicCollection: Bool
    var meta: NftMeta?
    var image: UIImage?
    var collectionName: String?
    
    static func ==(lhs: Nft, rhs: Nft) -> Bool {
        return lhs.metaUrl == rhs.metaUrl
    }
    
    static func empty() -> Nft {
        return Nft(tokenId: 0,
                   metaUrl: "",
                   contractAddress: "",
                   data: NftData(name: "",
                                 createDate: 0,
                                 filebaseName: nil),
                   isPublicCollection: false)
    }
}
