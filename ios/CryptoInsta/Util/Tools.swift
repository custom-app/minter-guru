//
//  Tools.swift
//  CryptoInsta
//
//  Created by Lev Baklanov on 04.06.2022.
//

import Foundation

class Tools {
    
    static func generatePictureName(address: String, format: String = "jpg") -> String {
        let addressCut = address.suffix(from: address.index(address.startIndex, offsetBy: 2))
        let timestamp = Date().timestamp()
        return "\(addressCut)_\(timestamp).\(format)"
    }
}
