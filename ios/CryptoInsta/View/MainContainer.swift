//
//  MainContainer.swift
//  CryptoInsta
//
//  Created by Lev Baklanov on 01.06.2022.
//

import SwiftUI

struct MainContainer: View {
    
    @EnvironmentObject
    var globalVm: GlobalViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { geometry in
                VStack {
                    Spacer()
                }
            }
            BottomMenu()
        }
        .background(Color.white)
    }
}
