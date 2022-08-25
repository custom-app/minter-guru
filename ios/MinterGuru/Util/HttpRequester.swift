//
//  HttpRequester.swift
//  CryptoInsta
//
//  Created by Lev Baklanov on 03.06.2022.
//

import Foundation
import AWSSigner

class HttpRequester {
    
    static let shared = HttpRequester()
    static private let HTTP_OK = 200
    static private let HEADER_CONTENT_TYPE = "Content-Type"
    static private let HEADER_AUTHORIZATION = "Authorization"
    static private let IMAGE_MIME_TYPE = "image/*"
    static private let JSON_MIME_TYPE = "application/json"
    
    func uploadPictureToFilebase(data: Data, filename: String, onResult: @escaping (String?, Error?) -> ()) {
        print("uploading picture")
        let credentials = StaticCredential(accessKeyId: Config.Filebase.key, secretAccessKey: Config.Filebase.secret)
        let signer = AWSSigner(credentials: credentials, name: "s3", region: "us-east-1")
        let url = URL(string:"https://\(Config.Filebase.bucket).\(Constants.Filebase.endpoint)/\(filename)")!
        let signedURL = signer.signURL(url: url, method: .PUT)
        var request = URLRequest(url: signedURL)
        request.httpMethod = "PUT"
        request.addValue(HttpRequester.IMAGE_MIME_TYPE,
                         forHTTPHeaderField: HttpRequester.HEADER_CONTENT_TYPE)
        request.httpBody = data
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
            if let error = error {
                print("response error: \(error)")
                DispatchQueue.main.async {
                    onResult(nil, error)
                }
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                print("error converting to httpresponse")
                DispatchQueue.main.async {
                    onResult(nil, InternalError.responseConvertingError(
                        description: "error converting to httpresponse"))
                }
                return
            }

            guard let data = data else {
                print("got nil data")
                DispatchQueue.main.async {
                    onResult(nil, InternalError.nilDataError)
                }
                return
            }
            print("image response code: \(httpResponse.statusCode)")
            if httpResponse.statusCode == HttpRequester.HTTP_OK {
                print("image response ok")
                if let cid = httpResponse.allHeaderFields["x-amz-meta-cid"] as? String, !cid.isEmpty {
                    print("image response cid: \(cid)")
                    DispatchQueue.main.async {
                        onResult(cid, nil)
                    }
                } else  {
                    DispatchQueue.main.async {
                        onResult(nil, InternalError.emptyCidError)
                    }
                }
            } else {
                let err = String(data: data, encoding: .utf8)! //TODO: handle
                print("response not ok: \(err)")
                DispatchQueue.main.async {
                    onResult(nil, InternalError.httpError(body: err))
                }
            }
        }
        task.resume()
    }
    
    func uploadMetaToFilebase(meta: NftMeta, filename: String, onResult: @escaping (String?, Error?) -> ()) {
        print("uploading meta")
        
        let encoder = JSONEncoder()
        let metaJson = try! encoder.encode(meta)
        print("Meta:\n\(String(data: metaJson, encoding: .utf8)!)")
        
        let credentials = StaticCredential(accessKeyId: Config.Filebase.key, secretAccessKey: Config.Filebase.secret)
        let signer = AWSSigner(credentials: credentials, name: "s3", region: "us-east-1")
        let url = URL(string:"https://\(Config.Filebase.bucket).\(Constants.Filebase.endpoint)/\(filename)")!
        let signedURL = signer.signURL(url: url, method: .PUT)
        var request = URLRequest(url: signedURL)
        request.httpMethod = "PUT"
        request.addValue(HttpRequester.JSON_MIME_TYPE,
                         forHTTPHeaderField: HttpRequester.HEADER_CONTENT_TYPE)
        request.httpBody = metaJson
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
            if let error = error {
                print("response error: \(error)")
                DispatchQueue.main.async {
                    onResult(nil, error)
                }
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                print("error converting to httpresponse")
                DispatchQueue.main.async {
                    onResult(nil, InternalError.responseConvertingError(
                        description: "error converting to httpresponse"))
                }
                return
            }

            guard let data = data else {
                print("got nil data")
                DispatchQueue.main.async {
                    onResult(nil, InternalError.nilDataError)
                }
                return
            }
            print("meta response code: \(httpResponse.statusCode)")
            if httpResponse.statusCode == HttpRequester.HTTP_OK {
                print("meta response ok")
                print("meta response: \(String(decoding: data, as: UTF8.self))")
                if let cid = httpResponse.allHeaderFields["x-amz-meta-cid"] as? String, !cid.isEmpty {
                    print("meta response cid: \(cid)")
                    DispatchQueue.main.async {
                        onResult(cid, nil)
                    }
                } else  {
                    DispatchQueue.main.async {
                        onResult(nil, InternalError.emptyCidError)
                    }
                }
            } else {
                let err = String(data: data, encoding: .utf8)! //TODO: handle
                print("response not ok: \(err)")
                DispatchQueue.main.async {
                    onResult(nil, InternalError.httpError(body: err))
                }
            }
        }
        task.resume()
    }
    
    func loadMeta(url: URL, onResult: @escaping (NftMeta?, Error?) -> ()) {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
            if let error = error {
                print("load meta response error: \(error)")
                DispatchQueue.main.async {
                    onResult(nil, error)
                }
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                print("load meta error converting to httpresponse")
                DispatchQueue.main.async {
                    onResult(nil, InternalError.responseConvertingError(
                        description: "error converting to httpresponse"))
                }
                return
            }

            guard let data = data else {
                print("got nil data on meta load")
                DispatchQueue.main.async {
                    onResult(nil, InternalError.nilDataError)
                }
                return
            }
            if httpResponse.statusCode == HttpRequester.HTTP_OK {
                print("load meta response ok")
                print("load meta response: \(String(decoding: data, as: UTF8.self))")
                do {
                    let response = try JSONDecoder().decode(NftMeta.self, from: data)
                    print("parsed response meta: \(response)")
                    DispatchQueue.main.async {
                        onResult(response, nil)
                    }
                } catch {
                    print("error decoding meta: \(error)")
                    DispatchQueue.main.async {
                        onResult(nil, error)
                    }
                }
            } else {
                let err = String(data: data, encoding: .utf8)! //TODO: handle
                print("response not ok: \(err)")
                DispatchQueue.main.async {
                    onResult(nil, InternalError.httpError(body: err))
                }
            }
        }
        task.resume()
    }
    
    func callFaucet(address: String, onResult: @escaping (FaucetResponse?, Error?) -> ()) {
        let encoder = JSONEncoder()
        let bodyJson = try! encoder.encode(AddressBody(address: address))
        doApiRequest(route: ApiRoute.callFaucet, data: bodyJson, onResult: onResult)
    }
    
    func checkFaucet(address: String, onResult: @escaping (FaucetUsageInfo?, Error?) -> ()) {
        let encoder = JSONEncoder()
        let bodyJson = try! encoder.encode(AddressBody(address: address))
        doApiRequest(route: ApiRoute.checkFaucet, data: bodyJson, onResult: onResult)
    }
    
    func getFaucetInfo(onResult: @escaping (FaucetInfo?, Error?) -> ()) {
        doApiRequest(route: ApiRoute.faucetInfo, data: Data(), onResult: onResult)
    }
    
    func getTwitterInfo(onResult: @escaping (TwitterInfo?, Error?) -> ()) {
        doApiRequest(route: ApiRoute.twitterInfo, data: Data(), onResult: onResult)
    }
    
    func applyForRepostReward(address: String, twitter: String, onResult: @escaping (RewardInfo?, Error?) -> ()) {
        let encoder = JSONEncoder()
        let bodyJson = try! encoder.encode(AddressWithTwitter(address: address, username: twitter))
        doApiRequest(route: ApiRoute.applyForTwitter, data: bodyJson, onResult: onResult)
    }
    
    func getRewards(address: String, onResult: @escaping ([RewardInfo]?, Error?) -> ()) {
        let encoder = JSONEncoder()
        let bodyJson = try! encoder.encode(AddressBody(address: address))
        doApiRequest(route: ApiRoute.twitterRewards, data: bodyJson, onResult: onResult)
    }
    
    func applyForTwitterFollow(address: String, twitter: String, onResult: @escaping (TwitterFollowReward?, Error?) -> ()) {
        let encoder = JSONEncoder()
        let bodyJson = try! encoder.encode(AddressWithTwitter(address: address, username: twitter))
        doApiRequest(route: ApiRoute.applyForTwitterFollow, data: bodyJson, onResult: onResult)
    }
    
    func checkTwitterFollow(address: String, onResult: @escaping (TwitterFollowReward?, Error?) -> ()) {
        let encoder = JSONEncoder()
        let bodyJson = try! encoder.encode(AddressBody(address: address))
        doApiRequest(route: ApiRoute.checkTwitterFollow, data: bodyJson, onResult: onResult)
    }
    
    func getTwitterFollowInfo(onResult: @escaping (TwitterFollowInfo?, Error?) -> ()) {
        doApiRequest(route: ApiRoute.twitterFollowInfo, data: Data(), onResult: onResult)
    }
    
    func getContractsConfig(onResult: @escaping (ContractsConfig?, Error?) -> ()) {
        doApiRequest(route: ApiRoute.contractsConfig, data: Data(), onResult: onResult)
    }
    
    func doApiRequest<T: Decodable>(route: ApiRoute, data: Data, onResult: @escaping (T?, Error?) -> Void) {
        let url = URL(string: Constants.backendUrl + route.rawValue)!
        print("doRequest on: " + url.absoluteString)
        var request = URLRequest(
            url: url,
            cachePolicy: .reloadIgnoringLocalCacheData
        )
        request.httpMethod = "POST"
        request.addValue(HttpRequester.JSON_MIME_TYPE, forHTTPHeaderField: HttpRequester.HEADER_CONTENT_TYPE)
        request.httpBody = data
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
            if let error = error {
                print("error: ", error)
                DispatchQueue.main.async {
                    onResult(nil, error)
                }
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    onResult(nil, InternalError.responseConvertingError(description: "error converting to httpresponse"))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    onResult(nil, InternalError.nilDataError)
                }
                return
            }
            if httpResponse.statusCode == HttpRequester.HTTP_OK {
                do {
                    let result = try JSONDecoder().decode(T.self, from: data)
                    DispatchQueue.main.async {
                        onResult(result, nil)
                    }
                } catch {
                    print("error decoding: \(error)\ndata: \(String(data: data, encoding: .utf8)!)")
                    do {
                        let error = try JSONDecoder().decode(ErrorResponse.self, from: data)
                        print("decoded error: \(error)")
                        DispatchQueue.main.async {
                            onResult(nil, InternalError.minterApiError(error: error))
                        }
                    } catch {
                        if let dataStr = String(data: data, encoding: .utf8), dataStr == "null\n" {
                            DispatchQueue.main.async {
                                onResult(nil, nil)
                            }
                        } else {
                            print("error decoding minter error: \(error)")
                        }
                    }
                }
            } else {
                let err = String(data: data, encoding: .utf8)! //TODO: handle
                print("response not ok: \(err)")
                do {
                    let error = try JSONDecoder().decode(ErrorResponse.self, from: data)
                    print("decoded error: \(error)")
                    DispatchQueue.main.async {
                        onResult(nil, InternalError.minterApiError(error: error))
                    }
                } catch {
                    print("error decoding minter error: \(error)")
                    DispatchQueue.main.async {
                        onResult(nil, InternalError.httpError(body: err))
                    }
                }
            }
        }
        task.resume()
    }
}
