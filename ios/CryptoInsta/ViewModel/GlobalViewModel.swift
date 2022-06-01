//
//  GlobalViewModel.swift
//  CryptoInsta
//
//  Created by Lev Baklanov on 01.06.2022.
//

import Foundation
import SwiftUI

class GlobalViewModel: ObservableObject {
    
    @Published
    var currentTab: TabItem = .wallet
    
}
