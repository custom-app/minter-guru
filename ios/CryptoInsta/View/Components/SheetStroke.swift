//
//  SheetStroke.swift
//  CryptoInsta
//
//  Created by Lev Baklanov on 17.06.2022.
//

import SwiftUI

struct SheetStroke: View {
    var body: some View {
        Rectangle()
            .fill(Colors.mainGrey)
            .frame(width: 54, height: 5)
            .cornerRadius(4)
            .padding(.top, 8)
    }
}

struct SheetStroke_Previews: PreviewProvider {
    static var previews: some View {
        SheetStroke()
    }
}
