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
                SheetStroke()
                    .padding(.bottom, 4)
                
                ScrollView {
                    VStack(spacing: 0) {
                        
                        Text("Connect crypto wallet")
                            .foregroundColor(Colors.darkGrey)
                            .font(.custom("rubik-bold", fixedSize: 28))
                            .padding(.top, 26)
                            .padding(.horizontal, 10)
                        
                        Text("Select the wallet")
                            .foregroundColor(Colors.mainGrey)
                            .font(.custom("rubik-bold", fixedSize: 24))
                            .padding(.top, 50)
                            .padding(.horizontal, 10)
                        
                        HStack(spacing: 0) {
                            
                            Spacer()
                            
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
                                        .shadow(color: selectedTrust ? Colors.mainPurple : Colors.darkGrey.opacity(0.15),
                                                radius: 10, x: 0, y: 0)
                                    
                                    Text("Trust Wallet")
                                        .foregroundColor(selectedTrust ? Colors.darkGrey : Colors.mainGrey)
                                        .font(.custom("rubik-bold", fixedSize: 18))
                                        .padding(.top, 16)
                                }
                            }
                            .padding(.trailing, 13)
                            
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
                                        .shadow(color: selectedTrust ? Colors.darkGrey.opacity(0.15) : Colors.mainPurple,
                                                radius: 10, x: 0, y: 0)
                                    
                                    Text("Metamask")
                                        .foregroundColor(selectedTrust ? Colors.mainGrey : Colors.darkGrey)
                                        .font(.custom("rubik-bold", fixedSize: 18))
                                        .padding(.top, 16)
                                }
                            }
                            .padding(.leading, 13)
                            
                            Spacer()
                        }
                        .padding(.top, 50)
                        .padding(.horizontal, 12)
                        
                        if selectedTrust {
                            Tip(text: "Recommended connection method.\nBefore connecting, please make sure that your wallet has the latest update. When you connect, make sure that the Polygon network is selected.")
                                .padding(.top, 50)
                                .padding(.horizontal, 26)
                        } else {
                            Tip(text: "Recommended for advanced users.\nYou must manually add the Polygon blockchain network to the Metamask.\nThere may also be problems with incorrect notifications. If you have any difficulties connecting the Metamask wallet, please read the Guides",
                                backgroundColor: Colors.paleRed)
                                .padding(.top, 50)
                                .padding(.horizontal, 26)
                        }

                        Button {
                            if selectedTrust {
                                globalVm.connect(wallet: Wallets.TrustWallet)
                            } else {
                                globalVm.connect(wallet: Wallets.Metamask)
                            }
                        } label: {
                            Text("Connect")
                                .font(.custom("rubik-bold", fixedSize: 17))
                                .foregroundColor(Colors.mainWhite)
                                .padding(.vertical, 17)
                                .padding(.horizontal, 45)
                                .background(Colors.mainGradient)
                                .cornerRadius(32)
                                .padding(.top, 50)
                                .shadow(color: Colors.mainGrey.opacity(0.15), radius: 20, x: 0, y: 0)
                        }
                        .padding(.bottom, 30)
                        
                    }
                    .frame(width: geometry.size.width)
                }
            }
            .frame(width: geometry.size.width)
        }
        .background(Color.white.ignoresSafeArea())
    }
}
