//
//  CollectionConstructor.swift
//  CryptoInsta
//
//  Created by Lev Baklanov on 11.07.2022.
//

import SwiftUI

struct CollectionConstructor: View {
    
    @EnvironmentObject
    var globalVm: GlobalViewModel
    
    @State
    var collectionName = ""
    
    var body: some View {
        
        VStack {
            
            TextField("", text: $collectionName)
                .font(.custom("rubik-bold", size: 17))
                .placeholder(when: collectionName.isEmpty) {
                    HStack {
                        Text("Collection name")
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
            
            Button {
                globalVm.purchaseCollection(collectionData: PrivateCollectionData(name: collectionName))
            } label: {
                Text("Create")
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
    }
}
