//
//  FaucetScreen.swift
//  CryptoInsta
//
//  Created by Lev Baklanov on 17.06.2022.
//

import SwiftUI

struct FaucetScreen: View {
    
    @EnvironmentObject
    var globalVm: GlobalViewModel
    
    @Binding
    var showingSheet: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            SheetStroke()
            
            if globalVm.faucetFinished {
                Spacer()
                HStack {
                    Spacer()
                    Text("Faucet successfully used!")
                        .foregroundColor(Colors.darkGrey)
                        .font(.custom("rubik-bold", fixedSize: 28))
                        .multilineTextAlignment(.center)
                        .padding(.top, 26)
                        .padding(.horizontal, 20)
                    Spacer()
                }
                
                Button {
                    showingSheet = false
                } label: {
                    Text("Go mint")
                        .font(.custom("rubik-bold", fixedSize: 17))
                        .foregroundColor(Colors.mainWhite)
                        .padding(.vertical, 17)
                        .padding(.horizontal, 60)
                        .background(Colors.mainGradient)
                        .cornerRadius(32)
                        .shadow(color: Colors.mainGrey.opacity(0.15), radius: 20, x: 0, y: 0)
                }
                .padding(.top, 50)
                
                Spacer()
            } else if globalVm.faucetProcessing {
                Spacer()
                
                Text("Processing faucet transaction")
                    .font(.custom("rubik-bold", fixedSize: 28))
                    .foregroundColor(Colors.darkGrey)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                
                MinterProgress()
                    .padding(.top, 50)
                
                Tip(text: "Please wait\nIt should take a few seconds")
                    .padding(.top, 50)
                    .padding(.horizontal, 26)
                
                Spacer()
            } else {
                Text("Faucet")
                    .foregroundColor(Colors.darkGrey)
                    .font(.custom("rubik-bold", fixedSize: 28))
                    .padding(.top, 26)
                    .padding(.horizontal, 10)
                
                Text("Get crypto coins to pay the fees")
                    .foregroundColor(Colors.mainGrey)
                    .multilineTextAlignment(.center)
                    .font(.custom("rubik-bold", fixedSize: 19))
                    .padding(.top, 10)
                    .padding(.horizontal, 10)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("How does it work?")
                        .foregroundColor(Colors.darkGrey)
                        .font(.custom("rubik-bold", fixedSize: 17))
                    
                    Text("We can gift you some Matics to pay for a transaction fee and try out our service. All you need to do is just click the button “Get Matic” below.")
                        .foregroundColor(Colors.darkGrey)
                        .font(.custom("rubik-regular", fixedSize: 17))
                    Text("It's free.")
                        .foregroundColor(Colors.darkGrey)
                        .font(.custom("rubik-regular", fixedSize: 17))
                }
                .padding(20)
                .background(Colors.mainWhite)
                .cornerRadius(30, corners: [.topLeft, .bottomRight])
                .cornerRadius(10, corners: [.bottomLeft, .topRight])
                .shadow(color: Colors.darkGrey.opacity(0.25), radius: 10, x: 0, y: 0)
                .padding(.top, 50)
                .padding(.horizontal, 26)
                
                if globalVm.faucetUsed {
                    FaucetUnusableView(reason: "Reuse of the Faucet is not available, please top up your crypto wallet account.\nIf you have any difficulties, please take a look at the “Guides” section")
                } else {
                    if let info = globalVm.faucetInfo, !info.open || info.spent == info.limit {
                        if !info.open {
                            FaucetUnusableView(reason: "Currently faucet is closed")
                        } else {
                            FaucetUnusableView(reason: "Today faucet usage limit is reached")
                        }
                    } else {
                        if globalVm.polygonBalance != 0 {
                            FaucetUnusableView(reason: "Faucet is only available if your Polygon wallet is empty")
                        } else {
                            if globalVm.isReconnecting {
                                MinterProgress()
                                    .padding(.top, 50)
                                
                                
                                Tip(text: "Reconnecting to your session\nPlease wait")
                                    .padding(.top, 25)
                                    .padding(.horizontal, 26)
                            } else {
                                Button {
                                    UserDefaultsWorker.shared.setFaucetUsed()
                                    globalVm.callFaucet()
                                } label: {
                                    Text("Get Matic")
                                        .font(.custom("rubik-bold", fixedSize: 17))
                                        .foregroundColor(Colors.mainWhite)
                                        .padding(.vertical, 17)
                                        .padding(.horizontal, 42)
                                        .background(Colors.mainGradient)
                                        .cornerRadius(32)
                                        .shadow(color: Colors.mainGrey.opacity(0.15), radius: 20, x: 0, y: 0)
                                }
                                .padding(.top, 50)
                            }
                        }
                    }
                }
                Spacer()
            }
        }
        .background(Colors.mainWhite.ignoresSafeArea())
    }
}

struct FaucetUnusableView: View {
    
    var reason: String
    
    var body: some View {
        VStack(spacing: 0) {
            Tip(text: reason,
                backgroundColor: Colors.paleRed)
                .padding(.top, 50)
                .padding(.horizontal, 26)
            
            Text("Get Matic")
                .font(.custom("rubik-bold", fixedSize: 17))
                .foregroundColor(Colors.mainWhite)
                .padding(.vertical, 17)
                .padding(.horizontal, 42)
                .background(Colors.mainGrey)
                .cornerRadius(32)
                .padding(.top, 50)
        }
    }
}
