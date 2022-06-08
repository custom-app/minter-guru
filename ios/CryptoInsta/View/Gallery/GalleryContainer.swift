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
    
    @State
    var selectedNft: NftObject?
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 18) {
                ForEach($globalVm.nftList) { nft in
                    NftListView(nft: nft, selectedNft: $selectedNft)
                }
            }
            .padding(.top, 30)
            .sheet(item: $selectedNft,
                   onDismiss: { selectedNft = nil }) { nft in
                if let index = globalVm.nftList.firstIndex(where: { $0.metaUrl == nft.metaUrl }) {
                    NftInfo(nft: $globalVm.nftList[index])
                        .environmentObject(globalVm)
                }
            }
        }
    }
}

struct NftListView: View {
    
    @Binding
    var nft: NftObject
    
    @Binding
    var selectedNft: NftObject?
    
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
        .onTapGesture {
            selectedNft = nft
        }
    }
}
