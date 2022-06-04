//
//  GalleryContainer.swift
//  CryptoInsta
//
//  Created by Lev Baklanov on 01.06.2022.
//

import SwiftUI

struct GalleryContainer: View {
    
    @EnvironmentObject
    var globalVm: GlobalViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 18) {
                ForEach(globalVm.nftList) { nft in
                    NftListView(nft: nft)
                }
            }
            .padding(.top, 30)
        }
    }
}

struct NftListView: View {
    
    var nft: NftObject
    
    var body: some View {
        HStack(spacing: 0) {
            Spacer()
            Text(nft.meta?.name ?? "Some nft")
                .foregroundColor(Color.purple)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 12)
            Spacer()
        }
        .padding(.vertical, 12)
        .background(Color.green.opacity(0.5))
        .cornerRadius(14)
        .padding(.horizontal, 20)
    }
}
