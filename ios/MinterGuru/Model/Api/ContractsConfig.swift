//
//  ContractsConfig.swift
//  MinterGuru
//
//  Created by Lev Baklanov on 25.08.2022.
//

import Foundation

struct ContractsConfig: Codable {
    let miguToken: String
    let accessToken: String
    let router: String
    
    enum CodingKeys: String, CodingKey {
        case miguToken = "token"
        case accessToken = "access_token"
        case router = "public_router"
    }
}
