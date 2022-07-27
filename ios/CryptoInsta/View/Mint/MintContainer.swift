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
                            .foregroundColor(Colors.mainBlack)
                            .font(.custom("rubik-bold", size: 28))
                            .padding(.top, 10)
                        
                        Text("Select a photo")
                            .foregroundColor(Colors.mainGrey)
                            .font(.custom("rubik-bold", size: 17))
                            .padding(.top, 25)
                            .padding(.horizontal, 10)
                        
                        if let image = globalVm.pickedImage {
                            
                            ZStack(alignment: .bottom) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
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
                                                    Text("Change")
                                                        .foregroundColor(Colors.mainGreen)
                                                        .font(.custom("rubik-bold", size: 17))
                                                    Spacer()
                                                }
                                                .padding(.vertical, 15)
                                                .background(LinearGradient(colors: [Color(hex: "#444444"), Color(hex: "#444444").opacity(0)],
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
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 60, height: 50)
                                        
                                        Text("Library")
                                            .foregroundColor(Colors.mainGreen)
                                            .font(.custom("rubik-bold", size: 16))
                                            .padding(.top, 8)
                                    }
                                    .padding(.horizontal, 37)
                                    .padding(.vertical, 24)
                                    .background(Colors.mainWhite)
                                    .cornerRadius(30, corners: [.topLeft, .bottomRight])
                                    .cornerRadius(10, corners: [.bottomLeft, .topRight])
                                    .shadow(color: Colors.mainBlack.opacity(0.25), radius: 10, x: 0, y: 0)
                                }
                                
                                Spacer()
                            }
                            .padding(.top, 10)
                        }
                        
                        TextField("", text: $globalVm.pictureName)
                            .font(.custom("rubik-bold", size: 17))
                            .placeholder(when: globalVm.pictureName.isEmpty) {
                                HStack {
                                    Text("Picture name")
                                        .font(.custom("rubik-bold", size: 17))
                                        .foregroundColor(Colors.mainGrey)
                                    Spacer()
                                }
                            }
                            .foregroundColor(Colors.mainBlack)
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 13)
                            .background(Colors.mainWhite)
                            .cornerRadius(32)
                            .overlay(
                                RoundedRectangle(cornerRadius: 32)
                                    .stroke(Colors.mainGreen, lineWidth: 2)
                            )
                            .padding(.horizontal, 26)
                            .padding(.top, 25)
                            .sheet(isPresented: $showPhotoPicker) {
                                PhotoPicker { image in
                                    print("image picked")
                                    showPhotoPicker = false
                                    guard let image = image else {
                                        print("image nil")
                                        withAnimation {
                                            globalVm.pickedImage = nil
                                        }
                                        return
                                    }
                                    globalVm.handleImagePicked(photo: image)
                                }
                            }
                        
                        Text("Collection")
                            .foregroundColor(Colors.mainGrey)
                            .font(.custom("rubik-bold", size: 17))
                            .padding(.top, 25)
                        
                        CollectionMenu(pickedPrivateCollection: $globalVm.pickedPrivateCollection)
                            .padding(.top, 10)
                        
                        if globalVm.pickedPrivateCollection {
                            VStack(spacing: 0) {
                                HStack(spacing: 10) {
                                    Text("Select a Private collection")
                                        .foregroundColor(Colors.mainGrey)
                                        .font(.custom("rubik-bold", size: 16))
                                    
                                    Button {
                                        showCreateCollectionSheet = true
                                    } label: {
                                        Text("Create")
                                            .foregroundColor(Colors.mainGreen)
                                            .font(.custom("rubik-bold", size: 16))
                                    }
                                }
                                
                            }
                            .padding(.top, 25)
                            
                            if globalVm.privateCollectionsLoaded {
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
                            } else {
                                MinterProgress()
                                    .padding(.top, 25)
                            }
                        }
                        
                        
                        if let image = globalVm.pickedImage {
                            
                            let zeroBalance = globalVm.polygonBalanceLoaded && globalVm.polygonBalance == 0
                            if !zeroBalance {
                                
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
                                            .font(.custom("rubik-bold", size: 17))
                                            .foregroundColor(Colors.mainGreen)
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
                            
                            Button {
                                globalVm.pictureName = globalVm.pictureName.trimmingCharacters(in: .whitespacesAndNewlines)
                                if globalVm.pictureName.isEmpty {
                                    globalVm.alert = IdentifiableAlert.build(
                                        id: "empty_name",
                                        title: "Empty name",
                                        message: "Please enter picture name")
                                    return
                                }
                                DispatchQueue.main.async {
                                    withAnimation {
                                        globalVm.mintInProgress = true
                                    }
                                    globalVm.objectWillChange.send()
                                    globalVm.vibrationWorker?.vibrate()
                                    globalVm.uploadImageToIpfs(image: image, name: globalVm.pictureName)
                                }
                            } label: {
                                Text("Mint")
                                    .font(.custom("rubik-bold", size: 17))
                                    .foregroundColor(Colors.mainWhite)
                                    .padding(.vertical, 17)
                                    .padding(.horizontal, 60)
                                    .background(LinearGradient(colors: [zeroBalance ? Colors.middleGrey : Colors.darkGreen,
                                                                        zeroBalance ? Colors.middleGrey : Colors.lightGreen],
                                                               startPoint: .leading,
                                                               endPoint: .trailing))
                                    .cornerRadius(32)
                                    .padding(.vertical, 25)
                                    .shadow(color: Colors.mainGreen.opacity(zeroBalance ? 0 : 0.5), radius: 10, x: 0, y: 0)
                            }
                            .disabled(zeroBalance)
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
                .foregroundColor(pickedPrivateCollection ? Colors.mainGreen : Colors.mainWhite)
                .font(.custom("rubik-bold", size: 16))
                .frame(width: 94)
                .padding(.vertical, 10)
                .background(pickedPrivateCollection ?
                            Color.clear.cornerRadius(30) : Colors.mainGreen.cornerRadius(30)
                )
                .onTapGesture {
                    if pickedPrivateCollection {
                        globalVm.vibrationWorker?.vibrate()
                        withAnimation {
                            pickedPrivateCollection = false
                        }
                    }
                }
            
            Text("Private")
                .foregroundColor(globalVm.isPassBought ?
                                 (pickedPrivateCollection ? Colors.mainWhite : Colors.mainGreen) : Colors.mainGrey
                )
                .font(.custom("rubik-bold", size: 16))
                .frame(width: 94)
                .padding(.vertical, 10)
                .background(pickedPrivateCollection ?
                            Colors.mainGreen.cornerRadius(30) : Color.clear.cornerRadius(30)
                )
                .onTapGesture {
                    if globalVm.isPassBought && !pickedPrivateCollection {
                        globalVm.vibrationWorker?.vibrate()
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
                .stroke(Colors.mainGreen, lineWidth: 2)
        )
    }
}
