//
//  Web3Parser.swift
//  CryptoInsta
//
//  Created by Lev Baklanov on 22.06.2022.
//

import Foundation
import web3swift
import BigInt

class Web3Parser {
    
    func parsePublicCollections(collections: [[AnyObject]]) throws -> [PublicCollectionData] {
        var res: [PublicCollectionData] = []
        for collection in collections {
            if collection.count < 2 {
                throw InternalError.structParseError(description: "Error collectionData parse: \(collection)")
            }
            guard let address = collection[0] as? EthereumAddress,
                  let version = collection[1] as? BigUInt else {
                      throw InternalError.structParseError(description: "Error collectionData parse: \(collection)")
            }
            let data = PublicCollectionData(address: address.address, version: Int(version))
            res.append(data)
        }
        return res
    }
    
    func parseTokens(tokens: [[[AnyObject]]]) throws -> [[TokenData]] {
        var res: [[TokenData]] = []
        for tokensArr in tokens {
            var resArr: [TokenData] = []
            for token in tokensArr {
                if token.count < 3 {
                    throw InternalError.structParseError(description: "Error tokenData parse: \(token)")
                }
                guard let id = token[0] as? BigUInt,
                      let metaUrl = token[1] as? String,
                      let data = token[2] as? Data else {
                          throw InternalError.structParseError(description: "Error tokenData parse: \(token)")
                }
                resArr.append(TokenData(id: Int(id), metaUrl: metaUrl, data: data))
            }
            res.append(resArr)
        }
        return res
    }
}
