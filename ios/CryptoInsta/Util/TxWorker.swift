//
//  TxWorker.swift
//  CryptoInsta
//
//  Created by Lev Baklanov on 22.06.2022.
//

import Foundation
import WalletConnectSwift

class TxWorker {
    
    static func construct(from: String,
                          to: String,
                          data: String = "",
                          value: String = "0x0") -> Client.Transaction {
        return Client.Transaction(from: from,
                                  to: to,
                                  data: data,
                                  gas: nil,
                                  gasPrice: nil,
                                  value: value,
                                  nonce: nil,
                                  type: nil,
                                  accessList: nil,
                                  chainId: nil,
                                  maxPriorityFeePerGas: nil,
                                  maxFeePerGas: nil)
    }
}
