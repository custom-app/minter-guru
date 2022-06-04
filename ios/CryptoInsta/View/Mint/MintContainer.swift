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
        VStack(spacing: 0) {
            Spacer()
            
            if let image = globalVm.pickedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(10)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 30)
            }
            
            if let image = globalVm.pickedImage {
                Button {
                    globalVm.uploadImageToIpfs(image: image, name: "Some name")
                } label: {
                    Text("Upload photo")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 26)
                        .padding(.vertical, 14)
                        .background(Color.green)
                        .cornerRadius(30)
                }
            } else {
                Button {
                    globalVm.checkGalleryAuth {
                        showPhotoPicker = true
                    }
                } label: {
                    Text("Pick photo")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 26)
                        .padding(.vertical, 14)
                        .background(Color.green)
                        .cornerRadius(30)
                }
                .padding(.bottom, 40)
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
            }
            
            Spacer()
        }
    }
}

struct MintContainer_Previews: PreviewProvider {
    static var previews: some View {
        MintContainer()
    }
}
