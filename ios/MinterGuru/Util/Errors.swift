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
    case responseConvertingError(description: String)
    case emptyCidError
    case invalidAddress(address: String)
    case unsuccessfullСontractRead(description: String)
    case structParseError(description: String)
    case unsuccessfulСontractRead(description: String)
    case nilDataError
    case httpError(body: String)
    case minterApiError(error: ErrorResponse)
    case nilContractMethodData(method: String)
    case nilClientOrSession
}
