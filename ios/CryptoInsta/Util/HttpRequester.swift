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
}
