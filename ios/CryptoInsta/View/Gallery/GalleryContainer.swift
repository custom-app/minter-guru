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
    var selectedNft: Nft?
    
    var body: some View {
        ScrollView(showsIndicators: true) {
            VStack(spacing: 0) {
                Text("Nft Album")
                    .foregroundColor(Colors.mainBlack)
                    .font(.custom("rubik-bold", size: 28))
                    .padding(.top, 10)
                
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach($globalVm.nftList) { nft in
                        let last = globalVm.nftList.last ?? Nft.empty()
                        NftListView(nft: nft,
                                    selectedNft: $selectedNft,
                                    isLast: last == nft.wrappedValue)
                    }
                }
                .padding(20)
                .background(Colors.mainWhite)
                .cornerRadius(30, corners: [.topLeft, .bottomRight])
                .cornerRadius(10, corners: [.bottomLeft, .topRight])
                .shadow(color: Colors.mainBlack.opacity(0.25), radius: 10, x: 0, y: 0)
                .padding(.top, 25)
                .padding(.horizontal, 26)
                .sheet(item: $selectedNft,
                       onDismiss: { selectedNft = nil }) { nft in
                    if let index = globalVm.nftList.firstIndex(where: { $0.metaUrl == nft.metaUrl }) {
                        NftInfoSheet(nft: $globalVm.nftList[index])
                    }
                }
            }
        }
    }
}

struct NftListView: View {
    
    @Binding
    var nft: Nft
    
    @Binding
    var selectedNft: Nft?
    
    var isLast: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                selectedNft = nft
            } label: {
                HStack {
                    Text(nft.data.name)
                        .foregroundColor(Colors.mainGreen)
                        .font(.custom("rubik-bold", size: 17))
                    Spacer()
                }
            }
            
            if !isLast {
                Rectangle()
                    .fill(Color(hex: "#EAEAEA"))
                    .frame(height: 1)
                    .padding(.vertical, 10)
            }
        }
    }
}
