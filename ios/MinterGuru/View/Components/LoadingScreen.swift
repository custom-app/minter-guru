//
//  LoadingScreen.swift
//  CryptoInsta
//
//  Created by Lev Baklanov on 20.07.2022.
//

import SwiftUI

struct LoadingScreen: View {
    
    var text: String
    
    var body: some View {
        VStack {
            MinterProgress()
        }
    }
}
