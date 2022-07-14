//
//  Web3Worker.swift
//  CryptoInsta
//
//  Created by Lev Baklanov on 02.06.2022.
//

import Foundation
import web3swift
import BigInt

class Web3Worker: ObservableObject {
    
    let zeroAddress = "0x0000000000000000000000000000000000000000"
    
    private let web3: web3
    private let parser: Web3Parser
    private let routerContract: EthereumContract
    private let routerContractWeb3: web3.web3contract
    private let accessTokenContract: EthereumContract
    private let accessTokenContractWeb3: web3.web3contract
    private let minterContract: EthereumContract
    private let minterContractWeb3: web3.web3contract
    private let privateCollectionContract: EthereumContract
    
    init(endpoint: String) {
        let chainId = BigUInt(Constants.requiredChainId)
        web3 = web3swift.web3(provider: Web3HttpProvider(URL(string: endpoint)!,
                                                         network: Networks.Custom(networkID: chainId))!)
        parser = Web3Parser()
        let routerPath = Bundle.main.path(forResource: "public_router_abi", ofType: "json")!
        let accessTokenPath = Bundle.main.path(forResource: "access_token_abi", ofType: "json")!
        let minterTokenPath = Bundle.main.path(forResource: "migu_token_abi", ofType: "json")!
        let privateCollectionPath = Bundle.main.path(forResource: "private_collection_abi", ofType: "json")!
        let routerAbi = try! String(contentsOfFile: routerPath)
        let accessTokenAbi = try! String(contentsOfFile: accessTokenPath)
        let minterAbi = try! String(contentsOfFile: minterTokenPath)
        let privateCollectionAbi = try! String(contentsOfFile: privateCollectionPath)
        routerContract = EthereumContract(routerAbi)!
        routerContractWeb3 = web3.contract(routerAbi, at: EthereumAddress(Constants.routerAddress)!, abiVersion: 2)!
        accessTokenContract = EthereumContract(accessTokenAbi)!
        accessTokenContractWeb3 = web3.contract(accessTokenAbi, at: EthereumAddress(Constants.accessTokenAddress)!, abiVersion: 2)!
        minterContract = EthereumContract(minterAbi)!
        minterContractWeb3 = web3.contract(minterAbi, at: EthereumAddress(Constants.minterAddress)!, abiVersion: 2)!
        privateCollectionContract = EthereumContract(privateCollectionAbi)!
    }
    
    func getBalance(address: String, onResult: @escaping (Double, Error?) -> ()) {
        if let walletAddress = EthereumAddress(address) {
            DispatchQueue.global(qos: .userInitiated).async { [self] in
                do {
                    let balanceResult = try web3.eth.getBalance(address: walletAddress)
                    let balanceString = Web3.Utils.formatToEthereumUnits(balanceResult, toUnits: .eth, decimals: 6)!
                    print("Balance: \(balanceString)")
                    DispatchQueue.main.async {
                        if let balance = Double(balanceString) {
                            onResult(balance, nil)
                        } else {
                            onResult(0, InternalError.balanceParseError)
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        onResult(0, error)
                    }
                }
            }
        } else {
            onResult(0, InternalError.invalidAddress(address: address))
        }
    }
    
    func getGasPrice(onResult: @escaping (BigUInt, Error?) -> ()) {
        DispatchQueue.global(qos: .userInitiated).async { [self] in
            do {
                let estimateGasPrice = try web3.eth.getGasPrice()
                print("Gas price: \(estimateGasPrice)")
                DispatchQueue.main.async {
                    onResult(estimateGasPrice, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    onResult(0, error)
                }
            }
        }
    }
    
    func getPublicTokensCount(address: String, onResult: @escaping (BigUInt, Error?) -> ()) {
        if let walletAddress = EthereumAddress(address) {
            DispatchQueue.global(qos: .userInitiated).async { [self] in
                do {
                    var options = TransactionOptions.defaultOptions
                    options.from = walletAddress
                    options.gasPrice = .automatic
                    options.gasLimit = .automatic
                    let tx = routerContractWeb3.read(
                        "totalTokens",
                        extraData: Data(),
                        transactionOptions: options)!
                    let result = try tx.call()
                    
                    print("Got public tokens count response:\n\(result)")
                    if let success = result["_success"] as? Bool, !success {
                        DispatchQueue.main.async {
                            onResult(0, InternalError.unsuccessfullСontractRead(description: "get public tokens count: \(result)"))
                        }
                    } else {
                        let count = result["0"] as! BigUInt
                        DispatchQueue.main.async {
                            onResult(count, nil)
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        onResult(0, error)
                    }
                }
            }
        } else {
            onResult(0, InternalError.invalidAddress(address: address))
        }
    }
    
    func getPublicTokens(page: Int, size: Int, address: String, onResult: @escaping ([Nft], Error?) -> ()) {
        if let walletAddress = EthereumAddress(address) {
            DispatchQueue.global(qos: .userInitiated).async { [self] in
                do {
                    var options = TransactionOptions.defaultOptions
                    options.from = walletAddress
                    options.gasPrice = .automatic
                    options.gasLimit = .automatic
                    let parameters: [AnyObject] = [
                        BigUInt(page) as AnyObject,
                        BigUInt(size) as AnyObject
                    ]
                    let tx = routerContractWeb3.read(
                        "getSelfPublicTokens",
                        parameters: parameters,
                        extraData: Data(),
                        transactionOptions: options)!
                    let result = try tx.call()
                    
//                    print("Got public tokens response:\n\(result)")
                    if let success = result["_success"] as? Bool, !success {
                        DispatchQueue.main.async {
                            onResult([], InternalError.unsuccessfullСontractRead(description: "get public tokens: \(result)"))
                        }
                    } else {
                        let collections = result["0"] as! [[AnyObject]]
                        let tokens = result["1"] as! [[[AnyObject]]]
//                        print("tokens: \(tokens)")
                        let collectionsData = try parser.parsePublicCollections(collections: collections)
                        let tokensData = try parser.parseTokens(tokens: tokens)
                        var nfts: [Nft] = []
                        let decoder = JSONDecoder()
                        for (i, tokensArr) in tokensData.enumerated() {
                            let collection = collectionsData[i]
                            for token in tokensArr {
                                let data = try decoder.decode(NftData.self, from: token.data)
                                let nft = Nft(
                                    id: token.id,
                                    metaUrl: token.metaUrl,
                                    contractAddress: collection.address,
                                    data: data,
                                    isPublicCollection: true)
                                nfts.append(nft)
                            }
                        }
                        onResult(nfts, nil)
                    }
                } catch {
                    DispatchQueue.main.async {
                        onResult([], error)
                    }
                }
            }
        } else {
            onResult([], InternalError.invalidAddress(address: address))
        }
    }
    
    func getPrivateCollectionPrice(onResult: @escaping (BigUInt, Error?) -> ()) {
        DispatchQueue.global(qos: .userInitiated).async { [self] in
            do {
                var options = TransactionOptions.defaultOptions
                options.gasPrice = .automatic
                options.gasLimit = .automatic
                let tx = accessTokenContractWeb3.read(
                    "collectionPrice",
                    extraData: Data(),
                    transactionOptions: options)!
                let result = try tx.call()
                
                print("Got collection price response:\n\(result)")
                if let success = result["_success"] as? Bool, !success {
                    DispatchQueue.main.async {
                        onResult(0, InternalError.unsuccessfullСontractRead(description: "get collection price: \(result)"))
                    }
                } else {
                    let price = result["0"] as! BigUInt
                    DispatchQueue.main.async {
                        onResult(price, nil)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    onResult(0, error)
                }
            }
        }
    }
    
    func getMinterBalance(address: String, onResult: @escaping (BigUInt, Error?) -> ()) {
        if let walletAddress = EthereumAddress(address) {
            DispatchQueue.global(qos: .userInitiated).async { [self] in
                do {
                    var options = TransactionOptions.defaultOptions
                    options.gasPrice = .automatic
                    options.gasLimit = .automatic
                    let parameters: [AnyObject] = [walletAddress as AnyObject]
                    let tx = minterContractWeb3.read(
                        "balanceOf",
                        parameters: parameters,
                        extraData: Data(),
                        transactionOptions: options)!
                    let result = try tx.call()
                    
                    print("Got minter balance response:\n\(result)")
                    if let success = result["_success"] as? Bool, !success {
                        DispatchQueue.main.async {
                            onResult(0, InternalError.unsuccessfullСontractRead(description: "get minter balance: \(result)"))
                        }
                    } else {
                        let balance = result["0"] as! BigUInt
                        DispatchQueue.main.async {
                            onResult(balance, nil)
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        onResult(0, error)
                    }
                }
            }
        } else {
            onResult(0, InternalError.invalidAddress(address: address))
        }
    }
    
    func getPrivateCollectionsGlobalCount(address: String, onResult: @escaping (BigUInt, Error?) -> ()) {
        if let walletAddress = EthereumAddress(address) {
            DispatchQueue.global(qos: .userInitiated).async { [self] in
                do {
                    var options = TransactionOptions.defaultOptions
                    options.from = walletAddress
                    options.gasPrice = .automatic
                    options.gasLimit = .automatic
                    let tx = accessTokenContractWeb3.read(
                        "tokensCount",
                        extraData: Data(),
                        transactionOptions: options)!
                    let result = try tx.call()
                    
                    print("Got private collections count response:\n\(result)")
                    if let success = result["_success"] as? Bool, !success {
                        DispatchQueue.main.async {
                            onResult(0, InternalError.unsuccessfullСontractRead(description: "get private collections count: \(result)"))
                        }
                    } else {
                        let count = result["0"] as! BigUInt
                        DispatchQueue.main.async {
                            onResult(count, nil)
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        onResult(0, error)
                    }
                }
            }
        } else {
            onResult(0, InternalError.invalidAddress(address: address))
        }
    }
    
    func getPrivateCollectionsCount(address: String, onResult: @escaping (BigUInt, Error?) -> ()) {
        if let walletAddress = EthereumAddress(address) {
            DispatchQueue.global(qos: .userInitiated).async { [self] in
                do {
                    var options = TransactionOptions.defaultOptions
                    options.gasPrice = .automatic
                    options.gasLimit = .automatic
                    let parameters: [AnyObject] = [walletAddress as AnyObject]
                    let tx = accessTokenContractWeb3.read(
                        "balanceOf",
                        parameters: parameters,
                        extraData: Data(),
                        transactionOptions: options)!
                    let result = try tx.call()
                    
                    print("Got private collections count response:\n\(result)")
                    if let success = result["_success"] as? Bool, !success {
                        DispatchQueue.main.async {
                            onResult(0, InternalError.unsuccessfullСontractRead(description: "get private collections count: \(result)"))
                        }
                    } else {
                        let balance = result["0"] as! BigUInt
                        DispatchQueue.main.async {
                            onResult(balance, nil)
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        onResult(0, error)
                    }
                }
            }
        } else {
            onResult(0, InternalError.invalidAddress(address: address))
        }
    }
    
    func getPrivateCollections(page: Int, size: Int = 1000, address: String, onResult: @escaping ([PrivateCollection], Error?) -> ()) {
        if let walletAddress = EthereumAddress(address) {
            DispatchQueue.global(qos: .userInitiated).async { [self] in
                do {
                    var options = TransactionOptions.defaultOptions
                    options.from = walletAddress
                    options.gasPrice = .automatic
                    options.gasLimit = .automatic
                    let parameters: [AnyObject] = [
                        BigUInt(page) as AnyObject,
                        BigUInt(size) as AnyObject
                    ]
                    let tx = accessTokenContractWeb3.read(
                        "getSelfCollections",
                        parameters: parameters,
                        extraData: Data(),
                        transactionOptions: options)!
                    let result = try tx.call()
                    
                    print("Got private collections response:\n\(result)")
                    if let success = result["_success"] as? Bool, !success {
                        DispatchQueue.main.async {
                            onResult([], InternalError.unsuccessfullСontractRead(description: "get private collections: \(result)"))
                        }
                    } else {
                        let collectionsData = result["0"] as! [[AnyObject]]
                        let counts = result["1"] as! [AnyObject]
                        let collections = try parser.parsePrivateCollections(collections: collectionsData, counts: counts)
                        onResult(collections, nil)
                    }
                } catch {
                    DispatchQueue.main.async {
                        onResult([], error)
                    }
                }
            }
        } else {
            onResult([], InternalError.invalidAddress(address: address))
        }
    }
    
    func getPrivateTokens(collections: [PrivateCollection],
                          ids: [BigUInt],
                          pages: [BigUInt],
                          sizes: [BigUInt],
                          address: String,
                          onResult: @escaping ([Nft], Error?) -> ()) {
        if let walletAddress = EthereumAddress(address) {
            DispatchQueue.global(qos: .userInitiated).async { [self] in
                do {
                    var options = TransactionOptions.defaultOptions
                    options.from = walletAddress
                    options.gasPrice = .automatic
                    options.gasLimit = .automatic
                    let parameters: [AnyObject] = [
                        ids as AnyObject,
                        pages as AnyObject,
                        sizes as AnyObject
                    ]
                    let tx = routerContractWeb3.read(
                        "getSelfTokens",
                        parameters: parameters,
                        extraData: Data(),
                        transactionOptions: options)!
                    let result = try tx.call()
                    
                    print("Got private tokens response:\n\(result)")
                    if let success = result["_success"] as? Bool, !success {
                        DispatchQueue.main.async {
                            onResult([], InternalError.unsuccessfullСontractRead(description: "get private tokens: \(result)"))
                        }
                    } else {
                        let tokens = result["0"] as! [[[AnyObject]]]
                        let tokensData = try parser.parseTokens(tokens: tokens)
                        var nfts: [Nft] = []
                        let decoder = JSONDecoder()
                        for (i, tokensArr) in tokensData.enumerated() {
                            for token in tokensArr {
                                let data = try decoder.decode(NftData.self, from: token.data)
                                let nft = Nft(
                                    id: token.id,
                                    metaUrl: token.metaUrl,
                                    contractAddress: collections[i].address,
                                    data: data,
                                    isPublicCollection: true,
                                    collectionName: collections[i].data.name)
                                nfts.append(nft)
                            }
                        }
                        onResult(nfts, nil)
                    }
                } catch {
                    DispatchQueue.main.async {
                        onResult([], error)
                    }
                }
            }
        } else {
            onResult([], InternalError.invalidAddress(address: address))
        }
    }
    
    func mintData(version: BigUInt, id: BigUInt, metaUrl: String, data: Data) -> String? {
        return encodeFunctionData(contract: routerContract,
                                  method: "mint",
                                  parameters: [version as AnyObject,
                                               id as AnyObject,
                                               metaUrl as AnyObject,
                                               data as AnyObject])?.toHexString(withPrefix: true)
    }
    
    func mintWithoutIdData(version: BigUInt, metaUrl: String, data: Data) -> String? {
        return encodeFunctionData(contract: routerContract,
                                  method: "mintWithoutId",
                                  parameters: [version as AnyObject,
                                               metaUrl as AnyObject,
                                               data as AnyObject])?.toHexString(withPrefix: true)
    }
    
    func privateMintData(to: EthereumAddress, metaUrl: String, data: Data) -> String? {
        return encodeFunctionData(contract: privateCollectionContract,
                                  method: "mintWithoutId",
                                  parameters: [to as AnyObject,
                                               metaUrl as AnyObject,
                                               data as AnyObject])?.toHexString(withPrefix: true)
    }
    
    func purchasePrivateCollectionData(salt: Data, name: String, symbol: String, data: Data) -> String? {
        return encodeFunctionData(contract: accessTokenContract,
                                  method: "purchasePrivateCollection",
                                  parameters: [salt as AnyObject,
                                               name as AnyObject,
                                               symbol as AnyObject,
                                               data as AnyObject])?.toHexString(withPrefix: true)
    }
    
    private func encodeFunctionData(contract: EthereumContract, method: String, parameters: [AnyObject] = [AnyObject]()) -> Data? {
        let foundMethod = contract.methods.filter { (key, value) -> Bool in
            return key == method
        }
        guard foundMethod.count == 1 else { return nil }
        let abiMethod = foundMethod[method]
        return abiMethod?.encodeParameters(parameters)
    }
}