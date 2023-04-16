//
//  MintFinishedSheet.swift
//  CryptoInsta
//
//  Created by Lev Baklanov on 19.06.2022.
//

import SwiftUI
import BigInt

struct MintFinishedSheet: View {
    
    @EnvironmentObject
    var globalVm: GlobalViewModel
    
    @State
    var textForShare: String? = nil
    
    @State
    var showMinterInfo = false
    
    var body: some View {
        VStack(spacing: 0) {
            SheetStroke()
                .padding(.bottom, 4)
            
            ScrollView {
                VStack(spacing: 0) {
                    Text("Minted!")
                        .foregroundColor(Colors.darkGrey)
                        .font(.custom("rubik-bold", fixedSize: 28))
                        .padding(.top, 26)
                    
                    if let image = globalVm.mintedImage {
                        VStack(spacing: 10) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .background(Color.white)
                                .cornerRadius(10)
                                .frame(maxWidth: .infinity, maxHeight: 325)
                            
                            Text(globalVm.mintedPictureName)
                                .foregroundColor(Colors.darkGrey)
                                .font(.custom("rubik-bold", fixedSize: 24))
                            
                            let collection = globalVm.mintedPictureCollection
                            Text(collection.isEmpty ? "#Public collection" : "#\(collection)")
                                .foregroundColor(Colors.mainGrey)
                                .font(.custom("rubik-bold", fixedSize: 18))
                        }
                        .padding(25)
                        .background(Colors.mainWhite)
                        .cornerRadius(10)
                        .shadow(color: Colors.darkGrey.opacity(0.25), radius: 10, x: 0, y: 0)
                        .padding(.horizontal, 26)
                        .padding(.top, 25)
                    }
                    if let nft = globalVm.getMintedNft() {
                        Button {
                            if let url = URL(string: Tools.formOpenseaLink(contract: nft.contractAddress, tokenId: nft.tokenId)),
                               UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                            } else {
                                //TODO: show error alert
                            }
                        } label: {
                            Text("Watch on the OpenSea")
                                .foregroundColor(Colors.mainPurple)
                                .font(.custom("rubik-bold", fixedSize: 17))
                                .padding(.top, 10)
                        }
                        
                        Text("*Nft will be available on OpenSea in a few minutes")
                            .font(.custom("rubik-regular", fixedSize: 13))
                            .foregroundColor(Colors.mainGrey)
                            .padding(.top, 6)
                            .padding(.horizontal, 26)
                        
                        Button {
                            globalVm.applyForRepostReward()
                            textForShare = "\(Tools.formOpenseaLink(contract: nft.contractAddress, tokenId: nft.tokenId))\n\(Constants.minterHashtag)"
                        } label: {
                            Text("Share")
                                .font(.custom("rubik-bold", fixedSize: 17))
                                .foregroundColor(Colors.mainWhite)
                                .padding(.vertical, 17)
                                .padding(.horizontal, 58)
                                .background(Colors.mainGradient)
                                .cornerRadius(32)
                                .padding(.top, 25)
                                .shadow(color: Colors.mainGrey.opacity(0.15), radius: 20, x: 0, y: 0)
                        }
                        
                        if globalVm.isRepostRewarded() {
                            let value = globalVm.twitterInfo == nil ? "" : Tools.formatUint256(BigUInt(globalVm.twitterInfo!.value)!, decimals: 0)
                            Tip(text: "You can earn \(value) MIGU tokens by sharing photo on social networks")
                                .padding(.horizontal, 26)
                                .padding(.top, 25)
                        
                            Button {
                                showMinterInfo = true
                            } label: {
                                Text("More info")
                                    .foregroundColor(Colors.mainPurple)
                                    .font(.custom("rubik-bold", fixedSize: 16))
                            }
                            .padding(.vertical, 10)
                            .sheet(isPresented: $showMinterInfo) {
                                MinterInfoScreen()
                                    .environmentObject(globalVm)
                            }
                        }
                    }
                }
            }
            .sheet(item: $textForShare,
                   onDismiss: { textForShare = nil }) { text in
                ShareView(activityItems: [text])
                    .ignoresSafeArea()
            }
        }
        .background(Color.white.ignoresSafeArea())
    }
}

struct MintFinishedSheet_Previews: PreviewProvider {
    static var previews: some View {
        MintFinishedSheet()
    }
}
