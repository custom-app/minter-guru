//
//  NftMeta.swift
//  CryptoInsta
//
//  Created by Lev Baklanov on 04.06.2022.
//

import Foundation

struct NftMeta: Codable {
    let name: String
    let description: String
    let image: String
    let properties: MetaProperties
    var collectionName: String?
    
    func httpImageLink() -> String {
        return Tools.ipfsLinkToHttp(ipfsLink: image)
    }
    
    func httpFilebaseLink() -> String {
        return Tools.ipfsLinkToFilebase(ipfsLink: image)
    }
    
    init(name: String, description: String, image: String, properties: MetaProperties) {
        self.name = name
        self.description = description
        self.image = image
        self.properties = properties
    }
    
    init() {
        name = ""
        description = ""
        image = ""
        properties = MetaProperties(
            id: "",
            imageName: ""
        )
    }
    
    func isEmpty() -> Bool {
        return name.isEmpty && description.isEmpty && image.isEmpty
    }
}

struct MetaProperties: Codable {
    let id: String
    let imageName: String
}
