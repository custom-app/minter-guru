//
//  ConnectSheet.swift
//  CryptoInsta
//
//  Created by Lev Baklanov on 15.06.2022.
//

import SwiftUI

struct ConnectSheet: View {
    
    @EnvironmentObject
    var globalVm: GlobalViewModel
    
    @State
    var selectedTrust = true
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                Rectangle()
                    .fill(Colors.mainGrey)
                    .frame(width: 54, height: 5)
                    .cornerRadius(4)
                    .padding(.top, 8)
                
                Text("Connect crypto wallet")
                    .foregroundColor(Colors.mainBlack)
                    .font(.custom("rubik-bold", size: 28))
                    .padding(.top, 26)
                    .padding(.horizontal, 10)
                
                Text("Select the wallet")
                    .foregroundColor(Colors.mainGrey)
                    .font(.custom("rubik-bold", size: 24))
                    .padding(.top, 50)
                    .padding(.horizontal, 10)
                
                HStack(spacing: 0) {
                    Button {
                        selectedTrust = true
                    } label: {
                        VStack(spacing: 0) {
                            Image("ic_trust")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .padding(25)
                                .background(Color.white)
                                .cornerRadius(30, corners: [.topLeft, .bottomRight])
                                .cornerRadius(10, corners: [.bottomLeft, .topRight])
                                .shadow(color: selectedTrust ? Colors.defaultGreen : Colors.mainBlack.opacity(0.15),
                                        radius: 10, x: 0, y: 0)
                            
                            Text("Trust Wallet")
                                .foregroundColor(selectedTrust ? Colors.mainBlack : Colors.mainGrey)
                                .font(.custom("rubik-bold", size: 18))
                                .padding(.top, 16)
                        }
                    }
                    
                    Spacer()
                    
                    Button {
                        selectedTrust = false
                    } label: {
                        VStack(spacing: 0) {
                            Image("ic_metamask")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .padding(25)
                                .background(Color.white)
                                .cornerRadius(30, corners: [.topLeft, .bottomRight])
                                .cornerRadius(10, corners: [.bottomLeft, .topRight])
                                .shadow(color: selectedTrust ? Colors.mainBlack.opacity(0.15) : Colors.defaultGreen,
                                        radius: 10, x: 0, y: 0)
                            
                            Text("Metamask")
                                .foregroundColor(selectedTrust ? Colors.mainGrey : Colors.mainBlack)
                                .font(.custom("rubik-bold", size: 18))
                                .padding(.top, 16)
                        }
                    }
                }
                .padding(.top, 50)
                .padding(.horizontal, 26)
                
                HStack(spacing: 0) {
                    Spacer()
                    Text("Before connecting, please make sure that you have latest wallet app version. Also make sure that you are connecting to Polygon blockchain")
                        .font(.custom("rubik-regular", size: 14))
                        .foregroundColor(Colors.mainGrey)
                        .multilineTextAlignment(.center)
                        .padding(10)
                    Spacer()
                }
                .background(Colors.paleGreen)
                .cornerRadius(10)
                .padding(.top, 50)
                .padding(.horizontal, 26)

                Button {
                    if selectedTrust {
                        globalVm.connect(wallet: Wallets.TrustWallet)
                    } else {
                        globalVm.connect(wallet: Wallets.Metamask)
                    }
                } label: {
                    Text("Connect")
                        .font(.custom("rubik-bold", size: 17))
                        .foregroundColor(Colors.mainWhite)
                        .padding(.vertical, 17)
                        .padding(.horizontal, 45)
                        .background(LinearGradient(colors: [Colors.darkGreen, Colors.lightGreen],
                                                   startPoint: .leading,
                                                   endPoint: .trailing))
                        .cornerRadius(32)
                        .padding(.top, 50)
                        .shadow(color: Colors.defaultGreen.opacity(0.5), radius: 10, x: 0, y: 0)
                }
                
            }
            .frame(width: geometry.size.width)
        }
        .background(Color.white.ignoresSafeArea())
    }
}
