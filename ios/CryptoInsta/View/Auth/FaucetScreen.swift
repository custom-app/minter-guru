//
//  FaucetScreen.swift
//  CryptoInsta
//
//  Created by Lev Baklanov on 17.06.2022.
//

import SwiftUI

struct FaucetScreen: View {
    
    var isUsed = false
    
    var body: some View {
        VStack(spacing: 0) {
            SheetStroke()
            
            Text("Faucet")
                .foregroundColor(Colors.mainBlack)
                .font(.custom("rubik-bold", size: 28))
                .padding(.top, 26)
                .padding(.horizontal, 10)
            
            Text("Get crypto coins to pay the fees")
                .foregroundColor(Colors.mainGrey)
                .multilineTextAlignment(.center)
                .font(.custom("rubik-bold", size: 19))
                .padding(.top, 10)
                .padding(.horizontal, 10)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("How does it work?")
                    .foregroundColor(Colors.mainBlack)
                    .font(.custom("rubik-bold", size: 17))
                
                Text("We can gift you some Matics to pay for a transaction fee and try out our service. All you need to do is just click the button “Get Matic” below.")
                    .foregroundColor(Colors.mainBlack)
                    .font(.custom("rubik-regular", size: 17))
                Text("It's free.")
                    .foregroundColor(Colors.mainBlack)
                    .font(.custom("rubik-regular", size: 17))
            }
            .padding(20)
            .background(Colors.mainWhite)
            .cornerRadius(30, corners: [.topLeft, .bottomRight])
            .cornerRadius(10, corners: [.bottomLeft, .topRight])
            .shadow(color: Colors.mainBlack.opacity(0.25), radius: 10, x: 0, y: 0)
            .padding(.top, 50)
            .padding(.horizontal, 26)
            
            if isUsed {
                
                Tip(text: "Reuse of the Faucet is not available, please top up your crypto wallet account.\nIf you have any difficulties, please take a look at the “Guides” section",
                    backgroundColor: Colors.paleRed)
                    .padding(.top, 50)
                    .padding(.horizontal, 26)
                
                Text("Get Matic")
                    .font(.custom("rubik-bold", size: 17))
                    .foregroundColor(Colors.mainWhite)
                    .padding(.vertical, 17)
                    .padding(.horizontal, 42)
                    .background(Colors.darkGrey)
                    .cornerRadius(32)
                    .padding(.top, 50)
            } else {
                Tip(text: "Transfer may take a few seconds, please refresh the state.")
                    .padding(.top, 50)
                    .padding(.horizontal, 26)
                
                Button {
                    
                } label: {
                    Text("Get Matic")
                        .font(.custom("rubik-bold", size: 17))
                        .foregroundColor(Colors.mainWhite)
                        .padding(.vertical, 17)
                        .padding(.horizontal, 42)
                        .background(LinearGradient(colors: [Colors.darkGreen, Colors.lightGreen],
                                                   startPoint: .leading,
                                                   endPoint: .trailing))
                        .cornerRadius(32)
                        .shadow(color: Colors.mainGreen.opacity(0.5), radius: 10, x: 0, y: 0)
                }
                .padding(.top, 50)
            }
            Spacer()
        }
        .background(Colors.mainWhite.ignoresSafeArea())
    }
}
