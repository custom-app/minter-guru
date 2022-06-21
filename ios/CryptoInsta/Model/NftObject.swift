//
//  NftObject.swift
//  CryptoInsta
//
//  Created by Lev Baklanov on 04.06.2022.
//

import Foundation
import UIKit

struct NftObject: Identifiable, Equatable {
    let id = UUID()
    let metaUrl: String
    var meta: NftMeta?
    var image: UIImage?
    var collectionName: String?
    
    static func ==(lhs: NftObject, rhs: NftObject) -> Bool {
        return lhs.metaUrl == rhs.metaUrl
    }
}
