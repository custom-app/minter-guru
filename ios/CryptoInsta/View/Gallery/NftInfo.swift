//
//  NftInfo.swift
//  CryptoInsta
//
//  Created by Lev Baklanov on 04.06.2022.
//

import SwiftUI

struct NftInfo: View {
    
    @EnvironmentObject
    var globalVm: GlobalViewModel
    
    @Binding
    var nft: NftObject
    
    var body: some View {
        VStack(spacing: 0) {
            if let image = nft.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .padding(20)
            } else {
                Text("IMAGE LOADING")
            }
        }
        .onAppear {
            if nft.image == nil {
                globalVm.loadImage(nft: nft)
            }
        }
    }
}

