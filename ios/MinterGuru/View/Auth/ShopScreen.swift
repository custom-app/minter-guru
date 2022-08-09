//
//  CollectionConstructor.swift
//  CryptoInsta
//
//  Created by Lev Baklanov on 11.07.2022.
//

import SwiftUI

struct ShopScreen: View {
    
    @EnvironmentObject
    var globalVm: GlobalViewModel
    
    @State
    var collectionName = ""
    
    @Binding
    var showingSheet: Bool
    
    var body: some View {
        
        VStack(spacing: 0) {
            SheetStroke()
        
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 0) {
                        if globalVm.purchasingInProgress {
                            VStack(spacing: 0) {
                                
                                Text(globalVm.allowance >= globalVm.privateCollectionPrice ? "Purchasing in progress" : "Processing permission to use tokens")
                                    .font(.custom("rubik-bold", size: 28))
                                    .foregroundColor(Colors.darkGrey)
                                    .multilineTextAlignment(.center)
                                
                                MinterProgress()
                                    .padding(.top, 50)
                                
                                
                                Tip(text: "Please wait\nIt should take a few seconds to process the transaction\nYou will be redirected to the wallet app")
                                    .padding(.top, 50)
                                    .padding(.horizontal, 26)
                            }
                            .frame(height: geometry.size.height)
                        } else if globalVm.purchaseFinished {
                            VStack(spacing: 0) {
                                
                                Image("ic_ok_light")
                                    .renderingMode(.template)
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(Colors.mainPurple)
                                    .frame(width: 64, height: 64)
                                
                                Text("Success!")
                                    .font(.custom("rubik-bold", size: 28))
                                    .foregroundColor(Colors.darkGrey)
                                    .padding(.top, 20)
                                
                                Text("Your private collection")
                                    .foregroundColor(Colors.mainGrey)
                                    .multilineTextAlignment(.center)
                                    .font(.custom("rubik-bold", size: 19))
                                    .padding(.top, 10)
                                
                                Text("#\(collectionName)")
                                    .foregroundColor(Colors.mainGrey)
                                    .multilineTextAlignment(.center)
                                    .font(.custom("rubik-bold", size: 19))
                                    .padding(.top, 6)
                                
                                Text("has been created")
                                    .foregroundColor(Colors.mainGrey)
                                    .multilineTextAlignment(.center)
                                    .font(.custom("rubik-bold", size: 19))
                                    .padding(.top, 6)
                                
                                Button {
                                    withAnimation {
                                        showingSheet = false
                                    }
                                } label: {
                                    Text("Go mint")
                                        .font(.custom("rubik-bold", size: 17))
                                        .foregroundColor(Colors.mainWhite)
                                        .padding(.vertical, 17)
                                        .padding(.horizontal, 60)
                                        .background(Colors.mainGradient)
                                        .cornerRadius(32)
                                        .shadow(color: Colors.mainPurple.opacity(0.5), radius: 10, x: 0, y: 0)
                                }
                                .padding(.top, 50)
                            }
                            .frame(width: geometry.size.width-52, height: geometry.size.height)
                        } else {
                            
                            Text("Shop")
                                .foregroundColor(Colors.darkGrey)
                                .font(.custom("rubik-bold", size: 28))
                                .padding(.top, 26)
                            
                            Text("Buy a private collection")
                                .foregroundColor(Colors.mainGrey)
                                .multilineTextAlignment(.center)
                                .font(.custom("rubik-bold", size: 19))
                                .padding(.top, 10)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("About private collections")
                                    .foregroundColor(Colors.darkGrey)
                                    .font(.custom("rubik-bold", size: 17))
                                
                                Text("Buying a private collection means creating your personal NFT-collection with your own photos on the OpenSea that will be visible to other users.")
                                    .foregroundColor(Colors.darkGrey)
                                    .font(.custom("rubik-regular", size: 17))
                                
                                HStack(spacing: 0) {
                                    Text("Price:")
                                        .foregroundColor(Colors.darkGrey)
                                        .font(.custom("rubik-bold", size: 17))
                                    
                                    Image("ic_migu_token")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 18, height: 18)
                                        .padding(.leading, 12)
                                    
                                    Text(globalVm.privateCollectionPrice == 0 ? "loading" :
                                            "\(Tools.formatUint256(globalVm.privateCollectionPrice, decimals: 2))")
                                        .foregroundColor(Colors.darkGrey)
                                        .font(.custom("rubik-regular", size: 17))
                                        .padding(.leading, 5)
                                }
                                .padding(.top, 8)
                                
                            }
                            .padding(20)
                            .background(Colors.mainWhite)
                            .cornerRadius(30, corners: [.topLeft, .bottomRight])
                            .cornerRadius(10, corners: [.bottomLeft, .topRight])
                            .shadow(color: Colors.darkGrey.opacity(0.25), radius: 10, x: 0, y: 0)
                            .padding(.top, 50)
                            
                            TextField("", text: $collectionName)
                                .font(.custom("rubik-bold", size: 17))
                                .placeholder(when: collectionName.isEmpty) {
                                    HStack {
                                        Text("Enter collection name")
                                            .font(.custom("rubik-bold", size: 17))
                                            .foregroundColor(Colors.mainGrey)
                                        Spacer()
                                    }
                                }
                                .foregroundColor(Colors.darkGrey)
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 13)
                                .background(Colors.mainWhite)
                                .cornerRadius(32)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 32)
                                        .stroke(Colors.mainPurple, lineWidth: 2)
                                )
                                .padding(.top, 50)
                                .disabled(globalVm.purchasingInProgress)
                            
                            let enoughtAllowance = (globalVm.allowance >= globalVm.privateCollectionPrice) && globalVm.privateCollectionPriceLoaded
                            
                            if globalVm.session == nil {
                                Tip(text: "To purchase a private collection you need to connect the wallet")
                                    .padding(.vertical, 25)
                            } else {
                                Button {
                                    withAnimation {
                                        globalVm.purchasingInProgress = true
                                    }
                                    if enoughtAllowance {
                                        globalVm.purchaseCollection(collectionData: PrivateCollectionData(name: collectionName))
                                    } else {
                                        globalVm.approveTokens()
                                    }
                                } label: {
                                    Text("Create")
                                        .font(.custom("rubik-bold", size: 17))
                                        .foregroundColor(Colors.mainWhite)
                                        .padding(.vertical, 17)
                                        .padding(.horizontal, 60)
                                        .background(Colors.mainGradient)
                                        .cornerRadius(32)
                                        .shadow(color: Colors.mainPurple.opacity(0.5), radius: 10, x: 0, y: 0)
                                }
                                .padding(.top, 50)
                                
                                Tip(text: enoughtAllowance ? "Now you are ready to create collection!" :
                                        "First you need to give access to the use of MIGU tokens, and then make a purchase")
                                    .padding(.vertical, 25)
                            }
                        }
                    }
                    .padding(.horizontal, 26)
                }
            }
        }
        .background(Color.white.ignoresSafeArea())
    }
}
