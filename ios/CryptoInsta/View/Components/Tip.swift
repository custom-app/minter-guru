//
//  Tip.swift
//  CryptoInsta
//
//  Created by Lev Baklanov on 17.06.2022.
//

import SwiftUI

struct Tip: View {
    
    var text: String
    
    var body: some View {
        HStack(spacing: 0) {
            Spacer()
            Text(text)
                .font(.custom("rubik-regular", size: 14))
                .foregroundColor(Colors.mainGrey)
                .multilineTextAlignment(.center)
                .padding(10)
            Spacer()
        }
        .background(Colors.paleGreen)
        .cornerRadius(10)
    }
}
