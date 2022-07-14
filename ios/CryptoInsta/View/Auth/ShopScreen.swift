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
    
    var body: some View {
        
        VStack(spacing: 0) {
            SheetStroke()
        
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 0) {
                        if globalVm.purchasingInProgress {
                            VStack(spacing: 0) {
                                Text("Purchasing in progress")
                                    .font(.custom("rubik-bold", size: 28))
                                    .foregroundColor(Colors.mainBlack)
                                
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: Color.black))
                                    .padding(.top, 25)
                                
                                
                                Tip(text: "Please wait\nIt should take a few seconds to process the transaction")
                                    .padding(.top, 25)
                                    .padding(.horizontal, 26)
                            }
                            .frame(height: geometry.size.height)
                        } else if globalVm.purchaseFinished {
                            VStack(spacing: 0) {
                                Text("Purchased successfully")
                                    .font(.custom("rubik-bold", size: 28))
                                    .foregroundColor(Colors.mainBlack)
                                    .padding(.horizontal, 10)
                            }
                            .frame(height: geometry.size.height)
                        } else {
                            
                            Text("Shop")
                                .foregroundColor(Colors.mainBlack)
                                .font(.custom("rubik-bold", size: 28))
                                .padding(.top, 26)
                            
                            Text("Buy a private collection")
                                .foregroundColor(Colors.mainGrey)
                                .multilineTextAlignment(.center)
                                .font(.custom("rubik-bold", size: 19))
                                .padding(.top, 10)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("About private collections")
                                    .foregroundColor(Colors.mainBlack)
                                    .font(.custom("rubik-bold", size: 17))
                                
                                Text("Buying a private collection means creating your personal NFT-collection with your own photos on the OpenSea that will be visible to other users.")
                                    .foregroundColor(Colors.mainBlack)
                                    .font(.custom("rubik-regular", size: 17))
                                
                                HStack(spacing: 0) {
                                    Text("Price:")
                                        .foregroundColor(Colors.mainBlack)
                                        .font(.custom("rubik-bold", size: 17))
                                    
                                    Image("ic_cross")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 18, height: 18)
                                        .padding(.leading, 12)
                                    
                                    Text(globalVm.privateCollectionPrice == 0 ? "loading" :
                                            "\(Tools.formatUint256(globalVm.privateCollectionPrice, decimals: 2))")
                                        .foregroundColor(Colors.mainBlack)
                                        .font(.custom("rubik-regular", size: 17))
                                        .padding(.leading, 5)
                                }
                                .padding(.top, 8)
                                
                            }
                            .padding(20)
                            .background(Colors.mainWhite)
                            .cornerRadius(30, corners: [.topLeft, .bottomRight])
                            .cornerRadius(10, corners: [.bottomLeft, .topRight])
                            .shadow(color: Colors.mainBlack.opacity(0.25), radius: 10, x: 0, y: 0)
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
                                .foregroundColor(Colors.mainBlack)
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 13)
                                .background(Colors.mainWhite)
                                .cornerRadius(32)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 32)
                                        .stroke(Colors.mainGreen, lineWidth: 2)
                                )
                                .padding(.top, 50)
                            
                            Button {
                                globalVm.purchaseCollection(collectionData: PrivateCollectionData(name: collectionName))
                            } label: {
                                Text("Create")
                                    .font(.custom("rubik-bold", size: 17))
                                    .foregroundColor(Colors.mainWhite)
                                    .padding(.vertical, 17)
                                    .padding(.horizontal, 60)
                                    .background(LinearGradient(colors: [Colors.darkGreen, Colors.lightGreen],
                                                               startPoint: .leading,
                                                               endPoint: .trailing))
                                    .cornerRadius(32)
                                    .shadow(color: Colors.mainGreen.opacity(0.5), radius: 10, x: 0, y: 0)
                            }
                            .padding(.top, 50)
                        }
                    }
                    .padding(.horizontal, 26)
                }
            }
        }
        .background(Color.white.ignoresSafeArea())
    }
}