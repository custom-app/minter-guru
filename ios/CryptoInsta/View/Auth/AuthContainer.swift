//
//  AuthContainer.swift
//  CryptoInsta
//
//  Created by Lev Baklanov on 01.06.2022.
//

import SwiftUI

struct AuthContainer: View {
    
    @EnvironmentObject
    var globalVm: GlobalViewModel
    
    var body: some View {
        VStack {
            Button {
                globalVm.connect(wallet: Wallets.TrustWallet)
            } label: {
                HStack {
                    Spacer()
                    Text(Wallets.TrustWallet.name)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(Color.green)
                    Spacer()
                }
                .padding(.vertical, 15)
                .background(Color.white)
                .cornerRadius(32)
                .overlay(
                    RoundedRectangle(cornerRadius: 32)
                        .stroke(Color.green, lineWidth: 2)
                )
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 24)
            Button {
                globalVm.connect(wallet: Wallets.Metamask)
            } label: {
                HStack {
                    Spacer()
                    Text(Wallets.Metamask.name)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(Color.green)
                    Spacer()
                }
                .padding(.vertical, 15)
                .background(Color.white)
                .cornerRadius(32)
                .overlay(
                    RoundedRectangle(cornerRadius: 32)
                        .stroke(Color.green, lineWidth: 2)
                )
            }
            .padding(.horizontal, 30)
            Spacer()
        }
    }
}

struct AuthContainer_Previews: PreviewProvider {
    static var previews: some View {
        AuthContainer()
    }
}
