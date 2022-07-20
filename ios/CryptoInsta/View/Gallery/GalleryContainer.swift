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
        GeometryReader { geometry in
            ScrollView(showsIndicators: true) {
                SwipeRefresh(bg: .black.opacity(0), fg: .black) {
                    if globalVm.privateCollectionsInGallery {
                        globalVm.refreshPrivateNfts()
                    } else {
                        globalVm.refreshPublicNfts()
                    }
                }
                
                VStack(spacing: 0) {
                    Text("Nft Album")
                        .foregroundColor(Colors.mainBlack)
                        .font(.custom("rubik-bold", size: 28))
                        .padding(.top, 10)
                    
                    Text("Collections")
                        .foregroundColor(Colors.mainGrey)
                        .font(.custom("rubik-bold", size: 17))
                        .padding(.top, 25)
                    
                    CollectionMenu(pickedPrivateCollection: $globalVm.privateCollectionsInGallery,
                                   chooseFirstPrivateCollection: false)
                        .padding(.top, 10)
                    
                    if globalVm.privateCollectionsInGallery && globalVm.privateCollectionsLoaded {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(globalVm.privateCollections, id: \.self) { collection in
                                    Text("#\(collection.data.name)")
                                        .foregroundColor(Colors.mainGreen)
                                        .font(.custom("rubik-bold", size: 16))
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 10)
                                        .background(Colors.paleGreen)
                                        .cornerRadius(30)
                                        .overlay(RoundedRectangle(cornerRadius: 30)
                                            .stroke(Colors.mainGreen, lineWidth: 2)
                                            .opacity(collection == globalVm.chosenCollectionInGallery ? 1 : 0))
                                        .onTapGesture {
                                            if collection == globalVm.chosenCollectionInGallery {
                                                withAnimation {
                                                    globalVm.chosenCollectionInGallery = nil
                                                }
                                            } else {
                                                withAnimation {
                                                    globalVm.chosenCollectionInGallery = collection
                                                }
                                            }
                                        }
                                    
                                }
                            }
                            .padding(.vertical, 10)
                            .padding(.horizontal, 26)
                        }
                    }
                    if globalVm.privateCollectionsInGallery {
                        if globalVm.refreshingPrivateNfts {
                            LoadingScreen(text: "")
                                .frame(width: geometry.size.width, height: geometry.size.height - 300)
                        } else {
                            if globalVm.privateNfts.isEmpty {
                                EmptyCollectionView(text: "This collections are empty")
                                    .frame(width: geometry.size.width, height: geometry.size.height - 300)
                            } else {
                                let nfts = globalVm.chosenCollectionInGallery == nil ? globalVm.privateNfts :
                                globalVm.privateNfts.filter({ $0.contractAddress == globalVm.chosenCollectionInGallery?.address })
                                if nfts.isEmpty {
                                    EmptyCollectionView(text: "This collection is empty")
                                        .frame(width: geometry.size.width, height: geometry.size.height - 300)
                                } else {
                                    LazyVStack(alignment: .leading, spacing: 0) {
                                        ForEach(nfts) { nft in
                                            let last = nfts.last ?? Nft.empty()
                                            NftListView(nft: nft,
                                                        selectedNft: $selectedNft,
                                                        isLast: last == nft)
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
                                        if let index = globalVm.privateNfts.firstIndex(where: { $0.metaUrl == nft.metaUrl }) {
                                            NftInfoSheet(nft: $globalVm.privateNfts[index])
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        if globalVm.refreshingPublicNfts {
                                LoadingScreen(text: "")
                                    .frame(width: geometry.size.width, height: geometry.size.height - 220)
                        } else {
                            if globalVm.publicNfts.isEmpty {
                                EmptyCollectionView(text: "There are no your nfts in the collection")
                                .frame(width: geometry.size.width, height: geometry.size.height - 220)
                            } else {
                                LazyVStack(alignment: .leading, spacing: 0) {
                                    ForEach(globalVm.publicNfts) { nft in
                                        let last = globalVm.publicNfts.last ?? Nft.empty()
                                        NftListView(nft: nft,
                                                    selectedNft: $selectedNft,
                                                    isLast: last == nft)
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
                                    if let index = globalVm.publicNfts.firstIndex(where: { $0.metaUrl == nft.metaUrl }) {
                                        NftInfoSheet(nft: $globalVm.publicNfts[index])
                                    }
                                }
                            }
                        }
                    }
                    
                }
            }
        }
    }
}

struct NftListView: View {
    
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

struct EmptyCollectionView: View {
    
    var text: String
    
    @EnvironmentObject
    var globalVm: GlobalViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            
            Text(text)
                .foregroundColor(Colors.mainGrey)
                .multilineTextAlignment(.center)
                .font(.custom("rubik-bold", size: 19))
                .padding(.horizontal, 20)
            
            Button {
                DispatchQueue.main.async {
                    withAnimation {
                        globalVm.currentTab = .mint
                    }
                    globalVm.objectWillChange.send()
                }
            } label: {
                Text("Mint now!")
                    .font(.custom("rubik-bold", size: 17))
                    .foregroundColor(Colors.mainWhite)
                    .padding(.vertical, 17)
                    .padding(.horizontal, 50)
                    .background(LinearGradient(colors: [Colors.darkGreen, Colors.lightGreen],
                                               startPoint: .leading,
                                               endPoint: .trailing))
                    .cornerRadius(32)
                    .shadow(color: Colors.mainGreen.opacity(0.5), radius: 10, x: 0, y: 0)
            }
            .padding(.top, 50)
        }
    }
    
}
