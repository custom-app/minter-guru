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
    
    @State
    var showGuides = false
    
    @State
    var showFaucet = false
    
    @State
    var showShop = false
    
    var body: some View {
        ScrollView {
            let connected = globalVm.session != nil
            VStack(spacing: 0) {
                Text("Crypto wallet")
                    .foregroundColor(Colors.mainBlack)
                    .font(.custom("rubik-bold", size: 28))
                    .padding(.top, 16)
                    .padding(.horizontal, 10)
                
                Text("Status: \(connected ? "connected to \(globalVm.walletName)" : "disconnected")")
                    .foregroundColor(Colors.mainGrey)
                    .multilineTextAlignment(.center)
                    .font(.custom("rubik-bold", size: 20))
                    .padding(.top, 10)
                    .padding(.horizontal, 10)
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("Address:")
                        .foregroundColor(Colors.mainBlack)
                        .font(.custom("rubik-bold", size: 16))
                    
                    HStack(spacing: 0) {
                        if connected {
                            Image("ic_cross")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 15, height: 15)
                            
                            HStack(spacing: 0) {
                                Text("\(globalVm.walletAccount ?? "")")
                                    .foregroundColor(Colors.mainBlack)
                                    .font(.custom("rubik-regular", size: 16))
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                                
                                Button {
                                    UIPasteboard.general.string = globalVm.walletAccount ?? ""
                                } label: {
                                    Image("ic_copy")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 20, height: 20)
                                }
                                .padding(.leading, 4)
                            }
                            .padding(.leading, 5)
                            .padding(.trailing, 20)
                        } else {
                            Image("ic_cross")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 15, height: 15)
                            
                            Text("wallet not connected")
                                .foregroundColor(Colors.mainBlack)
                                .font(.custom("rubik-regular", size: 16))
                                .padding(.leading, 5)
                        }
                    }
                    .padding(.top, 8)
                    
                    Rectangle()
                        .fill(Color(hex: "#EAEAEA"))
                        .frame(height: 1)
                        .padding(.top, 8)
                    
                    Text("Tokens:")
                        .foregroundColor(Colors.mainBlack)
                        .font(.custom("rubik-bold", size: 16))
                        .padding(.top, 8)
                    
                    HStack(spacing: 0) {
                        Image("ic_cross")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 15, height: 15)
                        
                        Text("tokens are not available")
                            .foregroundColor(Colors.mainBlack)
                            .font(.custom("rubik-regular", size: 16))
                            .padding(.leading, 5)
                    }
                    .padding(.top, 8)
                    
                    Button {
                        
                    } label: {
                        Text("How to earn")
                            .foregroundColor(Colors.mainGreen)
                            .font(.custom("rubik-bold", size: 16))
                            .padding(.top, 6)
                    }
                }
                .padding(20)
                .background(Colors.mainWhite)
                .cornerRadius(30, corners: [.topLeft, .bottomRight])
                .cornerRadius(10, corners: [.bottomLeft, .topRight])
                .shadow(color: Colors.mainBlack.opacity(0.25), radius: 10, x: 0, y: 0)
                .padding(.top, 25)
                .padding(.horizontal, 26)
                
                HStack(spacing: 0) {
                    VStack(spacing: 0) {
                        Button {
                            showGuides = true
                        } label: {
                            Image("ic_cross")
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(Colors.mainGreen)
                                .frame(width: 38, height: 38)
                                .padding(30)
                                .background(Colors.mainWhite)
                                .cornerRadius(30, corners: [.topLeft, .bottomRight])
                                .cornerRadius(10, corners: [.bottomLeft, .topRight])
                                .shadow(color: Colors.mainBlack.opacity(0.15), radius: 10, x: 0, y: 0)
                        }
                        
                        Text("Guides")
                            .foregroundColor(Colors.mainBlack)
                            .font(.custom("rubik-bold", size: 16))
                            .padding(.top, 10)
                    }
                    .sheet(isPresented: $showGuides) {
                        GuidesScreen()
                            .environmentObject(globalVm)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 0) {
                        Button {
                            showFaucet = true
                        } label: {
                            Image("ic_cross")
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .foregroundColor((connected && !globalVm.isWrongChain) ? Colors.mainGreen : Colors.darkGrey)
                                .frame(width: 38, height: 38)
                                .padding(30)
                                .background(Colors.mainWhite)
                                .cornerRadius(30, corners: [.topLeft, .bottomRight])
                                .cornerRadius(10, corners: [.bottomLeft, .topRight])
                                .shadow(color: Colors.mainBlack.opacity(0.15), radius: 10, x: 0, y: 0)
                        }
                        .disabled(!connected || globalVm.isWrongChain)
                        
                        Text("Faucet")
                            .foregroundColor(Colors.mainBlack)
                            .font(.custom("rubik-bold", size: 16))
                            .padding(.top, 10)
                    }
                    .sheet(isPresented: $showFaucet) {
                        FaucetScreen()
                            .environmentObject(globalVm)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 0) {
                        Button {
                            showShop = true
                        } label: {
                            Image("ic_cross")
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .foregroundColor((connected && !globalVm.isWrongChain) ? Colors.mainGreen : Colors.darkGrey)
                                .frame(width: 38, height: 38)
                                .padding(30)
                                .background(Colors.mainWhite)
                                .cornerRadius(30, corners: [.topLeft, .bottomRight])
                                .cornerRadius(10, corners: [.bottomLeft, .topRight])
                                .shadow(color: Colors.mainBlack.opacity(0.15), radius: 10, x: 0, y: 0)
                        }
                        .disabled(!connected || globalVm.isWrongChain)
                        
                        Text("Shop")
                            .foregroundColor(Colors.mainBlack)
                            .font(.custom("rubik-bold", size: 16))
                            .padding(.top, 10)
                    }
                    .sheet(isPresented: $showShop) {
                        GuidesScreen()
                            .environmentObject(globalVm)
                    }
                }
                .padding(.horizontal, 26)
                .padding(.top, 25)
                
                if !connected {
                    
                    Tip(text: "To use the main functions of the application, you need to connect a wallet")
                        .padding(.top, 25)
                        .padding(.horizontal, 26)
                    
                    Button {
                        globalVm.showConnectSheet = true
                    } label: {
                        HStack(spacing: 0) {
                            Spacer()
                            Text("Connect crypto wallet")
                                .font(.custom("rubik-bold", size: 17))
                                .fontWeight(.bold)
                                .foregroundColor(Colors.mainWhite)
                            Spacer()
                        }
                        .padding(.vertical, 15)
                        .background(LinearGradient(colors: [Colors.darkGreen, Colors.lightGreen],
                                                   startPoint: .leading,
                                                   endPoint: .trailing))
                        .cornerRadius(32)
                        .shadow(color: Colors.mainGreen.opacity(0.5), radius: 10, x: 0, y: 0)
                        .padding(.horizontal, 26)
                    }
                    .padding(.top, 26)
                    .sheet(isPresented: $globalVm.showConnectSheet) {
                        ConnectSheet()
                            .environmentObject(globalVm)
                    }
                } else {
                    if globalVm.isWrongChain {
                        HStack(spacing: 0) {
                            Spacer()
                            VStack(spacing: 0) {
                                Text("Wrong blockchain")
                                    .font(.custom("rubik-bold", size: 16))
                                    .foregroundColor(Colors.mainBlack)
                                    .multilineTextAlignment(.center)
                                
                                Text("Check out the guidelines to find out how to connect your wallet to the Polygon blockchain or change the wallet")
                                    .font(.custom("rubik-regular", size: 14))
                                    .foregroundColor(Colors.mainGrey)
                                    .multilineTextAlignment(.center)
                                    .padding(.top, 8)
                            }
                            .padding(10)
                            Spacer()
                        }
                        .background(Colors.paleRed)
                        .cornerRadius(10)
                        .padding(.horizontal, 26)
                        .padding(.top, 25)
                    }
                    Button {
                        globalVm.disconnect()
                    } label: {
                        Text("Disconnect")
                            .font(.custom("rubik-bold", size: 17))
                            .foregroundColor(Colors.mainGreen)
                            .padding(.vertical, 15)
                            .padding(.horizontal, 34)
                            .background(Colors.paleGreen)
                            .cornerRadius(32)
                            
                    }
                    .padding(.top, 25)
                }
                Spacer()
                    .frame(minHeight: 80)
            }
        }
    }
}

