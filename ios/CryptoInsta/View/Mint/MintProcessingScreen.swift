//
//  MintProcessingScreen.swift
//  CryptoInsta
//
//  Created by Lev Baklanov on 19.06.2022.
//

import SwiftUI

struct MintProcessingScreen: View {
    
    @EnvironmentObject
    var globalVm: GlobalViewModel
    
    var containerSize: CGSize
    
    var body: some View {
        VStack(spacing: 0) {
            
            let refreshingNfts = (globalVm.pickedPrivateCollection && globalVm.refreshingPrivateNfts) ||
                                 (!globalVm.pickedPrivateCollection && globalVm.refreshingPublicNfts)
            
            if refreshingNfts {
                MinterProgress()
            } else {
                Text("Minting in progress")
                    .font(.custom("rubik-bold", size: 28))
                    .foregroundColor(Colors.mainBlack)
                    .padding(.horizontal, 10)
                
                MinterProgress()
                    .padding(.top, 50)
                
                
                Tip(text: "Please wait\nIt should take a few seconds to process the transaction")
                    .padding(.top, 50)
                    .padding(.horizontal, 26)
            }
        }
        .frame(width: containerSize.width, height: containerSize.height)
    }
}
