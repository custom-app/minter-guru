//
//  MintContainer.swift
//  CryptoInsta
//
//  Created by Lev Baklanov on 01.06.2022.
//

import SwiftUI

struct MintContainer: View {
    
    @EnvironmentObject
    var globalVm: GlobalViewModel
    
    @State
    var showPhotoPicker = false
    
    @State
    var showCreateCollectionSheet = false
    
    @State
    var showFaucet = false
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: true) {
                
                SwipeRefresh(bg: .black.opacity(0), fg: .black) {
                    if globalVm.mintInProgress {
                        if globalVm.pickedPrivateCollection {
                            globalVm.refreshPrivateNfts()
                        } else {
                            globalVm.refreshPublicNfts()
                        }
                    } else {
                        globalVm.getPolygonBalance()
                        globalVm.getPrivateCollections()
                    }
                }
                
                if globalVm.mintInProgress {
                    MintProcessingScreen(containerSize: geometry.size)
                } else {
                    VStack(spacing: 0) {
                        
                        Text("Minting")
                            .foregroundColor(Colors.darkGrey)
                            .font(.custom("rubik-bold", fixedSize: 28))
                            .padding(.top, 10)
                        
                        Text("Select a photo")
                            .foregroundColor(Colors.mainGrey)
                            .font(.custom("rubik-bold", fixedSize: 17))
                            .padding(.top, 25)
                            .padding(.horizontal, 10)
                        
                        if let image = globalVm.pickedImage {
                            
                            ZStack(alignment: .bottom) {
                                Image(uiImage: image.image)
                                    .resizable()
                                    .scaledToFit()
                                    .background(Color.white)
                                    .overlay(
                                        Button {
                                            globalVm.checkGalleryAuth {
                                                showPhotoPicker = true
                                            }
                                        } label: {
                                            VStack {
                                                Spacer()
                                                HStack {
                                                    Spacer()
                                                    Text("Edit")
                                                        .foregroundColor(Colors.mainPurple)
                                                        .font(.custom("rubik-bold", fixedSize: 17))
                                                    Spacer()
                                                }
                                                .padding(.vertical, 12)
                                                .background(LinearGradient(colors: [Color.black.opacity(0.8), Color.black.opacity(0.6)],
                                                                           startPoint: .bottom, endPoint: .top))
                                            }
                                        }
                                    )
                                    .background(Color.black)
                                    .cornerRadius(10)
                                    .frame(maxWidth: .infinity, maxHeight: 325)
                                    .padding(.horizontal, 26)
                                    .padding(.top, 10)
                            }
                                     
                        } else {
                            HStack {
                                Spacer()
                                
                                Button {
                                    globalVm.checkGalleryAuth {
                                        showPhotoPicker = true
                                    }
                                } label: {
                                    VStack(alignment: .leading, spacing: 0) {
                                        Image("ic_image")
                                            .renderingMode(.template)
                                            .resizable()
                                            .scaledToFit()
                                            .foregroundColor(Colors.mainPurple)
                                            .frame(width: 60, height: 50)
                                        
                                        Text("Library")
                                            .foregroundColor(Colors.mainPurple)
                                            .font(.custom("rubik-bold", fixedSize: 16))
                                            .padding(.top, 8)
                                    }
                                    .padding(.horizontal, 37)
                                    .padding(.vertical, 24)
                                    .background(Colors.mainWhite)
                                    .cornerRadius(30, corners: [.topLeft, .bottomRight])
                                    .cornerRadius(10, corners: [.bottomLeft, .topRight])
                                    .shadow(color: Colors.darkGrey.opacity(0.25), radius: 10, x: 0, y: 0)
                                }
                                
                                Spacer()
                            }
                            .padding(.top, 10)
                        }
                        
                        TextField("", text: $globalVm.pictureName)
                            .font(.custom("rubik-bold", fixedSize: 17))
                            .placeholder(when: globalVm.pictureName.isEmpty) {
                                HStack {
                                    Text("Picture name")
                                        .font(.custom("rubik-bold", fixedSize: 17))
                                        .foregroundColor(Colors.mainGrey)
                                    Spacer()
                                }
                            }
                            .foregroundColor(Colors.darkGrey)
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 13)
                            .background(Colors.mainWhite)
                            .cornerRadius(32)
                            .overlay(
                                RoundedRectangle(cornerRadius: 32)
                                    .stroke(Colors.mainPurple, lineWidth: 2)
                            )
                            .disabled(globalVm.mintInProgress)
                            .padding(.horizontal, 26)
                            .padding(.top, 25)
                            .sheet(isPresented: $showPhotoPicker) {
                                PhotoPicker { image in
                                    print("image picked")
                                    showPhotoPicker = false
                                    guard let image = image else {
                                        print("image nil")
                                        withAnimation {
//                                            globalVm.pickedImage = nil
                                        }
                                        return
                                    }
                                    globalVm.handleImagePicked(photo: image)
                                }
                            }
                        
                        Text("Collection")
                            .foregroundColor(Colors.mainGrey)
                            .font(.custom("rubik-bold", fixedSize: 17))
                            .padding(.top, 25)
                        
                        CollectionMenu(pickedPrivateCollection: $globalVm.pickedPrivateCollection)
                            .padding(.top, 10)
                        
                        if globalVm.pickedPrivateCollection {
                            VStack(spacing: 0) {
                                HStack(spacing: 10) {
                                    Text("Select a Private collection")
                                        .foregroundColor(Colors.mainGrey)
                                        .font(.custom("rubik-bold", fixedSize: 16))
                                    
                                    Button {
                                        showCreateCollectionSheet = true
                                    } label: {
                                        Text("Create")
                                            .foregroundColor(Colors.mainPurple)
                                            .font(.custom("rubik-bold", fixedSize: 16))
                                    }
                                }
                                
                            }
                            .padding(.top, 25)
                            
                            if globalVm.privateCollectionsLoaded {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 10) {
                                        ForEach(globalVm.privateCollections, id: \.self) { collection in
                                            Text("#\(collection.data.name)")
                                                .foregroundColor(Colors.mainPurple)
                                                .font(.custom("rubik-bold", fixedSize: 16))
                                                .padding(.vertical, 8)
                                                .padding(.horizontal, 10)
                                                .background(Colors.palePurple)
                                                .cornerRadius(30)
                                                .overlay(RoundedRectangle(cornerRadius: 30)
                                                    .stroke(Colors.mainPurple, lineWidth: 2)
                                                    .opacity(collection == globalVm.pickedCollection ? 1 : 0))
                                                .onTapGesture {
                                                    if collection != globalVm.pickedCollection {
                                                        withAnimation {
                                                            globalVm.pickedCollection = collection
                                                        }
                                                    }
                                                }
                                            
                                        }
                                    }
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 26)
                                }
                                
                                if globalVm.privateCollections.isEmpty {
                                    Tip(text: "Private Collections is an advanced feature that can be purchased. You can buy your own private collections in the shop section.")
                                        .padding(.horizontal, 26)
                                        .padding(.top, 10)
                                }
                            } else if globalVm.session != nil || globalVm.connectedAddress != nil {
                                MinterProgress()
                                    .padding(.top, 20)
                            }
                        }
                        
                        
                        if let image = globalVm.pickedImage {
                            
                            let zeroBalance = globalVm.polygonBalanceLoaded && globalVm.polygonBalance == 0
                            if zeroBalance {
                                
                                if globalVm.faucetUsed {
                                    Tip(text: "To mint a photo, you need to pay a commission to the blockchain network. Please top up your balance ")
                                        .padding(.top, 25)
                                        .padding(.horizontal, 26)
                                } else if !globalVm.pickedPrivateCollection || !globalVm.privateCollections.isEmpty {
                                    Tip(text: "To mint a photo, you need to pay a transaction fee. We can give you some crypto in the Faucet section")
                                        .padding(.top, 25)
                                        .padding(.horizontal, 26)
                                    
                                    Button {
                                        showFaucet = true
                                    } label: {
                                        Text("Faucet")
                                            .font(.custom("rubik-bold", fixedSize: 17))
                                            .foregroundColor(Colors.mainPurple)
                                    }
                                    .padding(.top, 10)
                                    .sheet(isPresented: $showFaucet, onDismiss: {
                                        withAnimation {
                                            globalVm.faucetProcessing = false
                                            globalVm.faucetFinished = false
                                        }
                                    }) {
                                        FaucetScreen(showingSheet: $showFaucet)
                                            .environmentObject(globalVm)
                                    }
                                }
                            }
                            
                            if globalVm.isReconnecting {
                                MinterProgress()
                                    .padding(.top, 40)
                                
                                Tip(text: "Reconnecting to your session\nPlease wait")
                                    .padding(.top, 25)
                                    .padding(.horizontal, 26)
                            } else {
                                Button {
                                    if globalVm.session == nil && (globalVm.connectedAddress == nil || !globalVm.isAgentAccount) {
                                        globalVm.alert = IdentifiableAlert.build(
                                            id: "wallet not connected",
                                            title: "Wallet not connected",
                                            message: "To mint a picture, you need to connect the wallet")
                                        return
                                    }
                                    if globalVm.isWrongChain {
                                        globalVm.alert = IdentifiableAlert.build(
                                            id: "wrong chain",
                                            title: "Wrong chain",
                                            message: "Please connect to the Polygon network in your wallet")
                                        return
                                    }
                                    if globalVm.pickedPrivateCollection && globalVm.privateCollections.isEmpty {
                                        globalVm.alert = IdentifiableAlert.build(
                                            id: "wrong chain",
                                            title: "Missing collection",
                                            message: "You don't have any private collections")
                                        return
                                    }
                                    globalVm.pictureName = globalVm.pictureName.trimmingCharacters(in: .whitespacesAndNewlines)
                                    if globalVm.pictureName.isEmpty {
                                        globalVm.alert = IdentifiableAlert.build(
                                            id: "empty_name",
                                            title: "Empty name",
                                            message: "Please enter picture name")
                                        return
                                    }
                                    DispatchQueue.main.async {
                                        hideKeyboard()
                                        withAnimation {
                                            globalVm.mintInProgress = true
                                        }
                                        globalVm.objectWillChange.send()
                                        globalVm.vibrationWorker.vibrate()
                                        globalVm.uploadImageToIpfs(image: image, name: globalVm.pictureName)
                                    }
                                } label: {
                                    Text("Mint")
                                        .font(.custom("rubik-bold", fixedSize: 17))
                                        .foregroundColor(Colors.mainWhite)
                                        .padding(.vertical, 17)
                                        .padding(.horizontal, 60)
                                        .background(zeroBalance ? LinearGradient(colors: [Colors.mainGrey, Colors.mainGrey],
                                                                                 startPoint: .leading,endPoint: .trailing) : Colors.mainGradient)
                                        .cornerRadius(32)
                                        .padding(.vertical, 25)
                                        .shadow(color: Colors.mainGrey.opacity(zeroBalance ? 0 : 0.15), radius: 10, x: 0, y: 0)
                                }
                                .disabled(zeroBalance)
                            }
                        }
                        
                        Spacer()
                            .frame(height: 100)
                    }
                }
                
                Rectangle()
                    .frame(height: 0)
                    .sheet(isPresented: $globalVm.showMintFinishedSheet) {
                        MintFinishedSheet()
                            .environmentObject(globalVm)
                    }
                
                Rectangle()
                    .frame(height: 0)
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
            .padding(.top, 0.1)
        }
    }
}

struct CollectionMenu: View {
    
    @Binding
    var pickedPrivateCollection: Bool
    
    var chooseFirstPrivateCollection: Bool = true
    
    @EnvironmentObject
    var globalVm: GlobalViewModel
    
    var body: some View {
        HStack(spacing: 6) {
            Text("Common")
                .foregroundColor(pickedPrivateCollection ? Colors.mainPurple : Colors.mainWhite)
                .font(.custom("rubik-bold", fixedSize: 16))
                .frame(width: 94)
                .padding(.vertical, 10)
                .background(pickedPrivateCollection ?
                            Color.clear.cornerRadius(30) : Colors.mainPurple.cornerRadius(30)
                )
                .onTapGesture {
                    if pickedPrivateCollection {
                        globalVm.vibrationWorker.vibrate()
                        withAnimation {
                            pickedPrivateCollection = false
                        }
                    }
                }
            
            Text("Private")
                .foregroundColor(globalVm.isPassBought ?
                                 (pickedPrivateCollection ? Colors.mainWhite : Colors.mainPurple) : Colors.mainGrey
                )
                .font(.custom("rubik-bold", fixedSize: 16))
                .frame(width: 94)
                .padding(.vertical, 10)
                .background(pickedPrivateCollection ?
                            Colors.mainPurple.cornerRadius(30) : Color.clear.cornerRadius(30)
                )
                .onTapGesture {
                    if globalVm.isPassBought && !pickedPrivateCollection {
                        globalVm.vibrationWorker.vibrate()
                        withAnimation {
                            pickedPrivateCollection = true
                        }
                        if chooseFirstPrivateCollection &&
                            globalVm.pickedCollection == nil && globalVm.privateCollections.count > 0 {
                            globalVm.pickedCollection = globalVm.privateCollections[0]
                        }
                    }
                }
            
        }
        .padding(4)
        .overlay(
            RoundedRectangle(cornerRadius: 30)
                .stroke(Colors.mainPurple, lineWidth: 2)
        )
    }
}
