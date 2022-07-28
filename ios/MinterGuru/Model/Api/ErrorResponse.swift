//
//  ErrorResponse.swift
//  CryptoInsta
//
//  Created by Lev Baklanov on 19.07.2022.
//

import Foundation

struct ErrorResponse: Codable {
    let code: Int
    let message: String
    let detail: String
}
