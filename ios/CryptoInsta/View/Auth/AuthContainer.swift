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
            if globalVm.session == nil {
                ZStack {
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
                    if globalVm.connectingWalletName == Wallets.TrustWallet.name {
                        HStack {
                            Spacer()
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                .scaleEffect(1.2)
                        }
                        .padding(.trailing, 10)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 24)
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
            } else {
                Button {
                    globalVm.disconnect()
                } label: {
                    HStack {
                        Spacer()
                        Text("Disconnect")
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
                .padding(.top, 30)
            }
            Spacer()
        }
    }
}

