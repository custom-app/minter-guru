//
//  Errors.swift
//  CryptoInsta
//
//  Created by Lev Baklanov on 01.06.2022.
//

import Foundation

enum InternalError: Error {
    case balanceParseError
    case keyGenerationError
    case invalidAddress(address: String)
    case structParseError(description: String)
    case unsuccessfullСontractRead(description: String)
    case nilDataError
    case httpError(body: String)
    case nilContractMethodData(method: String)
    case nilClientOrSession
}
