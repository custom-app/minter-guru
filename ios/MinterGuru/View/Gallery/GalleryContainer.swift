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
    
    @State
    var showCreateCollectionSheet = false
    
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
                        .foregroundColor(Colors.darkGrey)
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
                                        .foregroundColor(Colors.mainPurple)
                                        .font(.custom("rubik-bold", size: 16))
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 10)
                                        .background(Colors.palePurple)
                                        .cornerRadius(30)
                                        .overlay(RoundedRectangle(cornerRadius: 30)
                                            .stroke(Colors.mainPurple, lineWidth: 2)
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
                    
                    if globalVm.showSearch() {
                        let searchEmpty = globalVm.nftSearch.isEmpty
                        
                        TextField("", text: $globalVm.nftSearch.animation())
                            .font(.custom("rubik-bold", size: 17))
                            .placeholder(when: globalVm.nftSearch.isEmpty) {
                                HStack {
                                    Text("Nft name")
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
                            .padding(.trailing, searchEmpty ? 35 : 65)
                            .background(Colors.mainWhite)
                            .cornerRadius(32)
                            .overlay(
                                RoundedRectangle(cornerRadius: 32)
                                    .stroke(Colors.mainPurple, lineWidth: 2)
                            )
                            .overlay(
                             HStack {
                                 Spacer()
                                 Button {
                                     hideKeyboard()
                                 } label: {
                                     Image("ic_magnifier")
                                         .renderingMode(.template)
                                         .resizable()
                                         .scaledToFit()
                                         .foregroundColor(Colors.mainPurple)
                                         .frame(width: 22, height: 22)
                                 }
                                 .padding(.trailing, searchEmpty ? 16 : 6)
                                 
                                 if !searchEmpty {
                                     Button {
                                         hideKeyboard()
                                         withAnimation {
                                             globalVm.nftSearch = ""
                                         }
                                     } label: {
                                         Image("ic_cross_light")
                                             .renderingMode(.template)
                                             .resizable()
                                             .scaledToFit()
                                             .foregroundColor(Colors.mainPurple)
                                             .frame(width: 22, height: 22)
                                     }
                                     .padding(.trailing, 16)
                                 }
                             }
                            )
                            .padding(.horizontal, 26)
                            .padding(.top, 15)
                    }
                    if globalVm.privateCollectionsInGallery {
                        if globalVm.refreshingPrivateNfts {
                            LoadingScreen(text: "")
                                .frame(width: geometry.size.width, height: calcWindowHeight(fullHeight: geometry.size.height))
                        } else {
                            if globalVm.privateCollections.isEmpty {
                                VStack(spacing: 0) {
                                    
                                    Text("You don't have any private collections")
                                        .foregroundColor(Colors.mainGrey)
                                        .multilineTextAlignment(.center)
                                        .font(.custom("rubik-bold", size: 19))
                                        .padding(.horizontal, 20)
                                    
                                    Button {
                                        showCreateCollectionSheet = true
                                    } label: {
                                        Text("Create")
                                            .font(.custom("rubik-bold", size: 17))
                                            .foregroundColor(Colors.mainWhite)
                                            .padding(.vertical, 17)
                                            .padding(.horizontal, 50)
                                            .background(Colors.mainGradient)
                                            .cornerRadius(32)
                                            .shadow(color: Colors.mainPurple.opacity(0.5), radius: 10, x: 0, y: 0)
                                    }
                                    .padding(.top, 50)
                                    .sheet(isPresented: $showCreateCollectionSheet, onDismiss: {
                                        withAnimation {
                                            globalVm.purchasingInProgress = false
                                            globalVm.purchaseFinished = false
                                        }
                                    }) {
                                        ShopScreen(showingSheet: $showCreateCollectionSheet)
                                            .environmentObject(globalVm)
                                    }
                                }
                                .frame(width: geometry.size.width, height: calcWindowHeight(fullHeight: geometry.size.height))
                            } else {
                                if globalVm.privateNfts.isEmpty {
                                    EmptyCollectionView(text: "Your private collections are empty")
                                        .frame(width: geometry.size.width, height: calcWindowHeight(fullHeight: geometry.size.height))
                                } else {
                                    let nfts = globalVm.chosenCollectionInGallery == nil ? globalVm.privateNfts :
                                    globalVm.privateNfts.filter({ $0.contractAddress == globalVm.chosenCollectionInGallery?.address })
                                    let filteredNfts = (globalVm.nftSearch.isEmpty ? nfts :
                                        nfts.filter({ $0.data.name.lowercased().contains(globalVm.nftSearch.lowercased()) }))
                                        .sorted(by: { $0.data.createDate > $1.data.createDate })
                                    if filteredNfts.isEmpty && !nfts.isEmpty {
                                        VStack(spacing: 0) {
                                            Text("There is no NFTs with this name")
                                                .foregroundColor(Colors.mainGrey)
                                                .multilineTextAlignment(.center)
                                                .font(.custom("rubik-bold", size: 19))
                                                .padding(.horizontal, 20)
                                        }
                                        .frame(width: geometry.size.width, height: calcWindowHeight(fullHeight: geometry.size.height))
                                    }  else {
                                        if nfts.isEmpty {
                                            EmptyCollectionView(text: "This collection is empty")
                                                .frame(width: geometry.size.width, height: calcWindowHeight(fullHeight: geometry.size.height))
                                        } else {
                                            LazyVStack(alignment: .leading, spacing: 0) {
                                                ForEach(filteredNfts) { nft in
                                                    let last = filteredNfts.last ?? Nft.empty()
                                                    NftListView(nft: nft,
                                                                selectedNft: $selectedNft,
                                                                isLast: last == nft)
                                                }
                                            }
                                            .padding(20)
                                            .background(Colors.mainWhite)
                                            .cornerRadius(30, corners: [.topLeft, .bottomRight])
                                            .cornerRadius(10, corners: [.bottomLeft, .topRight])
                                            .shadow(color: Colors.darkGrey.opacity(0.25), radius: 10, x: 0, y: 0)
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
                            }
                        }
                    } else {
                        if globalVm.refreshingPublicNfts {
                                LoadingScreen(text: "")
                                    .frame(width: geometry.size.width, height: calcWindowHeight(fullHeight: geometry.size.height))
                        } else {
                            let filteredNfts = (globalVm.nftSearch.isEmpty ? globalVm.publicNfts :
                                globalVm.publicNfts.filter({ $0.data.name.lowercased().contains(globalVm.nftSearch.lowercased()) }))
                                .sorted(by: { $0.data.createDate > $1.data.createDate })
                            if filteredNfts.isEmpty && !globalVm.publicNfts.isEmpty {
                                VStack(spacing: 0) {
                                    Text("There is no NFTs with this name")
                                        .foregroundColor(Colors.mainGrey)
                                        .multilineTextAlignment(.center)
                                        .font(.custom("rubik-bold", size: 19))
                                        .padding(.horizontal, 20)
                                }
                                .frame(width: geometry.size.width, height: calcWindowHeight(fullHeight: geometry.size.height))
                            } else {
                                if globalVm.publicNfts.isEmpty {
                                    EmptyCollectionView(text: "There are no your nfts in the collection")
                                    .frame(width: geometry.size.width, height: calcWindowHeight(fullHeight: geometry.size.height))
                                } else {
                                    LazyVStack(alignment: .leading, spacing: 0) {
                                        ForEach(filteredNfts) { nft in
                                            let last = filteredNfts.last ?? Nft.empty()
                                            NftListView(nft: nft,
                                                        selectedNft: $selectedNft,
                                                        isLast: last == nft)
                                        }
                                    }
                                    .padding(20)
                                    .background(Colors.mainWhite)
                                    .cornerRadius(30, corners: [.topLeft, .bottomRight])
                                    .cornerRadius(10, corners: [.bottomLeft, .topRight])
                                    .shadow(color: Colors.darkGrey.opacity(0.25), radius: 10, x: 0, y: 0)
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
    
    func calcWindowHeight(fullHeight: CGFloat) -> CGFloat {
        var res = fullHeight - 220
        if globalVm.privateCollectionsInGallery && !globalVm.privateCollections.isEmpty {
            res -= 80
        }
        if globalVm.showSearch() {
            res -= 100
        }
        return res
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
                        .foregroundColor(Colors.mainPurple)
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
                    .background(Colors.mainGradient)
                    .cornerRadius(32)
                    .shadow(color: Colors.mainPurple.opacity(0.5), radius: 10, x: 0, y: 0)
            }
            .padding(.top, 50)
        }
    }
    
}
