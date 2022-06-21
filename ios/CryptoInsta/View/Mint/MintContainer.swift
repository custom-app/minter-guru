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
    
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: true) {
                
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
                        
                        CollectionMenu()
                            .padding(.top, 10)
                        
                        
                        if globalVm.pickedPrivateCollection {
                            Text("Choose a Private Collection")
                                .foregroundColor(Colors.mainGrey)
                                .font(.custom("rubik-bold", size: 17))
                                .padding(.top, 25)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(globalVm.privateCollections, id: \.self) { collection in
                                        Text("#\(collection)")
                                            .foregroundColor(Colors.mainGreen)
                                            .font(.custom("rubik-bold", size: 16))
                                            .padding(.vertical, 8)
                                            .padding(.horizontal, 10)
                                            .background(Colors.paleGreen)
                                            .cornerRadius(30)
                                            .overlay(RoundedRectangle(cornerRadius: 30)
                                                .stroke(Colors.mainGreen, lineWidth: 2)
                                                .opacity(collection == globalVm.pickedCollectionName ? 1 : 0))
                                            .onTapGesture {
                                                if collection != globalVm.pickedCollectionName {
                                                    withAnimation {
                                                        globalVm.pickedCollectionName = collection
                                                    }
                                                }
                                            }
                                        
                                    }
                                }
                                .padding(.vertical, 10)
                                .padding(.horizontal, 26)
                            }
                        }
                        
                        if let image = globalVm.pickedImage {
                            
                            Button {
                                if globalVm.pictureName.isEmpty {
                                    globalVm.alert = IdentifiableAlert.build(
                                        id: "empty_name",
                                        title: "Empty name",
                                        message: "Please enter picture name")
                                    return
                                }
                                withAnimation {
                                    globalVm.mintInProgress = true
                                }
                                globalVm.uploadImageToIpfs(image: image, name: globalVm.pictureName)
                            } label: {
                                Text("Mint")
                                    .font(.custom("rubik-bold", size: 17))
                                    .foregroundColor(Colors.mainWhite)
                                    .padding(.vertical, 17)
                                    .padding(.horizontal, 60)
                                    .background(LinearGradient(colors: [Colors.darkGreen, Colors.lightGreen],
                                                               startPoint: .leading,
                                                               endPoint: .trailing))
                                    .cornerRadius(32)
                                    .padding(.vertical, 25)
                                    .shadow(color: Colors.mainGreen.opacity(0.5), radius: 10, x: 0, y: 0)
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
            }
            .padding(.top, 0.1)
        }
    }
}

struct CollectionMenu: View {
    @EnvironmentObject
    var globalVm: GlobalViewModel
    
    var body: some View {
        HStack(spacing: 6) {
            Text("Common")
                .foregroundColor(globalVm.pickedPrivateCollection ? Colors.mainGreen : Colors.mainWhite)
                .font(.custom("rubik-bold", size: 16))
                .frame(width: 94)
                .padding(.vertical, 10)
                .background(globalVm.pickedPrivateCollection ?
                            Color.clear.cornerRadius(30) : Colors.mainGreen.cornerRadius(30)
                )
                .onTapGesture {
                    if globalVm.pickedPrivateCollection {
                        withAnimation {
                            globalVm.pickedPrivateCollection = false
                        }
                    }
                }
            
            Text("Private")
                .foregroundColor(globalVm.isPassBought ?
                                 (globalVm.pickedPrivateCollection ? Colors.mainWhite : Colors.mainGreen) : Colors.mainGrey
                )
                .font(.custom("rubik-bold", size: 16))
                .frame(width: 94)
                .padding(.vertical, 10)
                .background(globalVm.pickedPrivateCollection ?
                            Colors.mainGreen.cornerRadius(30) : Color.clear.cornerRadius(30)
                )
                .onTapGesture {
                    if globalVm.isPassBought && !globalVm.pickedPrivateCollection {
                        withAnimation {
                            globalVm.pickedPrivateCollection = true
                        }
                        if globalVm.pickedCollectionName == "" {
                            globalVm.pickedCollectionName = globalVm.privateCollections[0]
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
