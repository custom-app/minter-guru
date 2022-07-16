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
    
    func parsePublicCollections(collections: [[AnyObject]]) throws -> [PublicCollection] {
        var res: [PublicCollection] = []
        for collection in collections {
            if collection.count < 2 {
                throw InternalError.structParseError(description: "Error publicCollection parse: \(collection)")
            }
            guard let address = collection[0] as? EthereumAddress,
                  let version = collection[1] as? BigUInt else {
                      throw InternalError.structParseError(description: "Error publicCollection parse: \(collection)")
            }
            let data = PublicCollection(address: address.address, version: Int(version))
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
    
    func parsePrivateCollections(collections: [[AnyObject]], counts: [AnyObject]) throws -> [PrivateCollection] {
        var res: [PrivateCollection] = []
        let decoder = JSONDecoder()
        for (i, collection) in collections.enumerated() {
            if collection.count < 2 {
                throw InternalError.structParseError(description: "Error privateCollection parse: \(collection)")
            }
            guard let id = collection[0] as? BigUInt,
                  let address = collection[1] as? EthereumAddress,
                  let data = collection[2] as? Data,
                  let count = counts[i] as? BigUInt else {
                      throw InternalError.structParseError(description: "Error privateCollection parse: \(collection)")
            }
            let privateCollectionData = try decoder.decode(PrivateCollectionData.self, from: data)
            let privateCollection = PrivateCollection(id: id,
                                                      address: address.address,
                                                      tokensCount: Int(count),
                                                      data: privateCollectionData)
            res.append(privateCollection)
        }
        return res
    }
}
