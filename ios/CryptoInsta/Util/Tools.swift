//
//  Tools.swift
//  CryptoInsta
//
//  Created by Lev Baklanov on 04.06.2022.
//

import Foundation
import CommonCrypto
import web3swift
import BigInt

class Tools {
    
    static func generatePictureName(address: String) -> String {
        let addressCut = address.suffix(from: address.index(address.startIndex, offsetBy: 2))
        let timestamp = Date().timestamp()
        return "\(addressCut)_\(timestamp)"
    }
    
    static func sha256(data: Data) -> Data {
        var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
        }
        return Data(hash)
    }
    
    static func isAddressValid(_ address: String) -> Bool {
        EthereumAddress(address) != nil
    }
    
    static func ipfsLinkToHttp(ipfsLink: String) -> String {
        ipfsLink.replacingOccurrences(of: "ipfs://", with: "https://ipfs.filebase.io/ipfs/")
    }
    
    static func formFilebaseLink(filename: String) -> String {
        "https://\(Config.Filebase.bucket).s3.filebase.com/\(filename)"
    }
    
    static func cidFromIpfsLink(_ ipfsLink: String) -> String {
        ipfsLink.replacingOccurrences(of: "ipfs://", with: "")
    }
    
    static func formatUint256(_ count: BigUInt, decimals: Int = 2) -> String {
        return Web3.Utils.formatToEthereumUnits(count, toUnits: .eth, decimals: decimals)!
    }
    
    static func parseTwitter(twitter: String) -> (login: String, valid: Bool) {
        if twitter.isEmpty {
            return ("", false)
        }
        if twitter[0] == "@" {
            let nickname = twitter[1...]
            return (nickname, isTwitterNicknameValid(nickname: nickname))
        }
        if twitter.starts(with: Constants.twitterLink) {
            let nickname = twitter.replacingOccurrences(of: Constants.twitterLink, with: "")
            return (nickname, isTwitterNicknameValid(nickname: nickname))
        }
        return (twitter, isTwitterNicknameValid(nickname: twitter))
    }
    
    static func isTwitterNicknameValid(nickname: String) -> Bool {
        if nickname.length > 15 || nickname.length < 4 {
            return false
        }
        return Constants.twitterCharacters.isSuperset(of: CharacterSet(charactersIn: nickname))
    }
}
