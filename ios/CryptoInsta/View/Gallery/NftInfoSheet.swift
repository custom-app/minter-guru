//
//  NftInfo.swift
//  CryptoInsta
//
//  Created by Lev Baklanov on 04.06.2022.
//

import SwiftUI

struct NftInfoSheet: View {
    
    @EnvironmentObject
    var globalVm: GlobalViewModel
    
    @Binding
    var nft: Nft
    
    @State
    var textForShare: String? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                SheetStroke()
                Spacer()
            }
            
            ScrollView {
                VStack(spacing: 0) {
                    Text("NFT")
                        .foregroundColor(Colors.mainBlack)
                        .font(.custom("rubik-bold", size: 28))
                        .padding(.top, 26)
                    
                    VStack(spacing: 10) {
                        if let image = nft.image {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .background(Color.black)
                                .cornerRadius(10)
                                .frame(maxWidth: .infinity, maxHeight: 325)
                            
                            Text(nft.meta?.name ?? "")
                                .foregroundColor(Colors.mainBlack)
                                .font(.custom("rubik-bold", size: 24))
                            
                            if let collection = nft.collectionName {
                                Text(collection.isEmpty ? "#Public collection" : "#\(collection)")
                                    .foregroundColor(Colors.mainGrey)
                                    .font(.custom("rubik-bold", size: 18))
                            }
                        } else {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: Color.black))
                                .scaleEffect(1.5)
                                .padding(100)
                        }
                    }
                    .padding(25)
                    .background(Colors.mainWhite)
                    .cornerRadius(10)
                    .shadow(color: Colors.mainBlack.opacity(0.25), radius: 10, x: 0, y: 0)
                    .padding(.horizontal, 26)
                    .padding(.top, 25)
                    .onAppear {
                        if nft.image == nil {
                            globalVm.loadImage(nft: nft)
                        }
                    }
                    
                    Button {
                        //TODO: unmock
                        if let url = URL(string: "https://opensea.io/assets/matic/0xba21ce6b4dc183fa5d257584e657b913c90a69da/12"),
                           UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        } else {
                            //TODO: show error alert
                        }
                    } label: {
                        Text("Watch on the OpenSea")
                            .foregroundColor(Colors.mainGreen)
                            .font(.custom("rubik-bold", size: 17))
                            .padding(.top, 14)
                    }
                    
                    if let imageLink = nft.meta?.image {
                        Button {
                            if let url = URL(string: Tools.ipfsLinkToHttp(ipfsLink: imageLink)),
                               UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                            } else {
                                //TODO: show error alert
                            }
                        } label: {
                            Text("Watch on the IPFS")
                                .foregroundColor(Colors.mainGreen)
                                .font(.custom("rubik-bold", size: 17))
                                .padding(.top, 10)
                        }
                    }
                    
                    Button {
                        textForShare = "Some info to detect post\nhttps://opensea.io/assets/matic/0xba21ce6b4dc183fa5d257584e657b913c90a69da/12"
                    } label: {
                        Text("Share")
                            .font(.custom("rubik-bold", size: 17))
                            .foregroundColor(Colors.mainWhite)
                            .padding(.vertical, 17)
                            .padding(.horizontal, 58)
                            .background(LinearGradient(colors: [Colors.darkGreen, Colors.lightGreen],
                                                       startPoint: .leading,
                                                       endPoint: .trailing))
                            .cornerRadius(32)
                            .padding(.top, 25)
                            .shadow(color: Colors.mainGreen.opacity(0.5), radius: 10, x: 0, y: 0)
                    }
                    .sheet(item: $textForShare,
                           onDismiss: { textForShare = nil }) { text in
                        ShareView(activityItems: [text])
                            .ignoresSafeArea()
                    }
                }
            }
        }
        .background(Color.white.ignoresSafeArea())
    }
}

