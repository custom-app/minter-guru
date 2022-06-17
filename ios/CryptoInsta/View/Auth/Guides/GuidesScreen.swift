//
//  GuidesScreen.swift
//  CryptoInsta
//
//  Created by Lev Baklanov on 17.06.2022.
//

import SwiftUI

struct GuidesScreen: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                SheetStroke()
                
                Text("Guides")
                    .foregroundColor(Colors.mainBlack)
                    .font(.custom("rubik-bold", size: 28))
                    .padding(.top, 26)
                    .padding(.horizontal, 10)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Wallet:")
                        .foregroundColor(Colors.mainBlack)
                        .font(.custom("rubik-bold", size: 17))
                    
                    Button {
                        
                    } label: {
                        Text("Some guide 1")
                            .foregroundColor(Colors.defaultGreen)
                            .font(.custom("rubik-bold", size: 17))
                    }
                    
                    Rectangle()
                        .fill(Color(hex: "#EAEAEA"))
                        .frame(height: 1)
                    
                    Button {
                        
                    } label: {
                        Text("Some guide 2")
                            .foregroundColor(Colors.defaultGreen)
                            .font(.custom("rubik-bold", size: 17))
                    }
                    
                    Rectangle()
                        .fill(Color(hex: "#EAEAEA"))
                        .frame(height: 1)
                    
                    Button {
                        
                    } label: {
                        Text("Some guide 3")
                            .foregroundColor(Colors.defaultGreen)
                            .font(.custom("rubik-bold", size: 17))
                    }
                }
                .padding(20)
                .background(Colors.mainWhite)
                .cornerRadius(30, corners: [.topLeft, .bottomRight])
                .cornerRadius(10, corners: [.bottomLeft, .topRight])
                .shadow(color: Colors.mainBlack.opacity(0.25), radius: 10, x: 0, y: 0)
                .padding(.top, 70)
                .padding(.horizontal, 26)
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("Tokens:")
                        .foregroundColor(Colors.mainBlack)
                        .font(.custom("rubik-bold", size: 17))
                    
                    Button {
                        
                    } label: {
                        Text("About")
                            .foregroundColor(Colors.defaultGreen)
                            .font(.custom("rubik-bold", size: 17))
                    }
                    .padding(.top, 8)
                    
                    Rectangle()
                        .fill(Color(hex: "#EAEAEA"))
                        .frame(height: 0)
                }
                .padding(20)
                .background(Colors.mainWhite)
                .cornerRadius(30, corners: [.topLeft, .bottomRight])
                .cornerRadius(10, corners: [.bottomLeft, .topRight])
                .shadow(color: Colors.mainBlack.opacity(0.25), radius: 10, x: 0, y: 0)
                .padding(.top, 10)
                .padding(.horizontal, 26)
                
                Tip(text: "Still have questions or technical problems? Let us know")
                    .padding(.top, 50)
                    .padding(.horizontal, 26)
                
                Button {
                    
                } label: {
                    Text("Help")
                        .foregroundColor(Colors.defaultGreen)
                        .font(.custom("rubik-bold", size: 17))
                }
                .padding(.top, 10)
                
            }
        }
        .background(Color.white.ignoresSafeArea())
    }
}
