//
//  Tip.swift
//  CryptoInsta
//
//  Created by Lev Baklanov on 17.06.2022.
//

import SwiftUI

struct Tip: View {
    
    var text: String
    
    var backgroundColor: Color = Colors.brightGreen.opacity(0.1)
    
    var body: some View {
        HStack(spacing: 0) {
            Spacer()
            Text(text)
                .font(.custom("rubik-regular", size: 14))
                .foregroundColor(Colors.darkGrey)
                .multilineTextAlignment(.center)
                .padding(10)
            Spacer()
        }
        .background(backgroundColor)
        .cornerRadius(10)
    }
}
