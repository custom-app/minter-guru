//
//  GuidesScreen.swift
//  CryptoInsta
//
//  Created by Lev Baklanov on 17.06.2022.
//

import SwiftUI

struct GuidesScreen: View {
    
    @EnvironmentObject
    var globalVm: GlobalViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            SheetStroke()
        
            ScrollView {
                VStack(spacing: 0) {
                    
                    Text("Guides")
                        .foregroundColor(Colors.darkGrey)
                        .font(.custom("rubik-bold", fixedSize: 28))
                        .padding(.top, 26)
                        .padding(.horizontal, 10)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Wallet:")
                            .foregroundColor(Colors.darkGrey)
                            .font(.custom("rubik-bold", fixedSize: 17))
                        
                        Button {
                            
                        } label: {
                            Text("Some guide 1")
                                .foregroundColor(Colors.mainPurple)
                                .font(.custom("rubik-bold", fixedSize: 17))
                        }
                        
                        Rectangle()
                            .fill(Color(hex: "#EAEAEA"))
                            .frame(height: 1)
                        
                        Button {
                            
                        } label: {
                            Text("Some guide 2")
                                .foregroundColor(Colors.mainPurple)
                                .font(.custom("rubik-bold", fixedSize: 17))
                        }
                        
                        Rectangle()
                            .fill(Color(hex: "#EAEAEA"))
                            .frame(height: 1)
                        
                        Button {
                            
                        } label: {
                            Text("Some guide 3")
                                .foregroundColor(Colors.mainPurple)
                                .font(.custom("rubik-bold", fixedSize: 17))
                        }
                    }
                    .padding(20)
                    .background(Colors.mainWhite)
                    .cornerRadius(30, corners: [.topLeft, .bottomRight])
                    .cornerRadius(10, corners: [.bottomLeft, .topRight])
                    .shadow(color: Colors.darkGrey.opacity(0.25), radius: 10, x: 0, y: 0)
                    .padding(.top, 70)
                    .padding(.horizontal, 26)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Tokens:")
                            .foregroundColor(Colors.darkGrey)
                            .font(.custom("rubik-bold", fixedSize: 17))
                        
                        Button {
                            
                        } label: {
                            Text("About")
                                .foregroundColor(Colors.mainPurple)
                                .font(.custom("rubik-bold", fixedSize: 17))
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
                    .shadow(color: Colors.darkGrey.opacity(0.25), radius: 10, x: 0, y: 0)
                    .padding(.top, 25)
                    .padding(.horizontal, 26)
                    
                    Button {
                        withAnimation {
                            globalVm.showingOnboarding = true
                        }
                    } label: {
                        Text("General guide")
                            .font(.custom("rubik-bold", fixedSize: 17))
                            .foregroundColor(Colors.mainWhite)
                            .padding(.vertical, 17)
                            .padding(.horizontal, 50)
                            .background(Colors.mainGradient)
                            .cornerRadius(32)
                            .shadow(color: Colors.mainGrey.opacity(0.15), radius: 20, x: 0, y: 0)
                    }
                    .padding(.top, 25)
                    
                    Tip(text: "Still have questions or technical problems? Let us know")
                        .padding(.top, 50)
                        .padding(.horizontal, 26)
                    
                    Button {
                        if let url = URL(string: Constants.minterTwitterLink),
                           UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        } else {
                            //TODO: handle error
                        }
                    } label: {
                        Text("Help")
                            .foregroundColor(Colors.mainPurple)
                            .font(.custom("rubik-bold", fixedSize: 17))
                    }
                    .padding(.top, 10)
                    
                }
            }
        }
        .background(Color.white.ignoresSafeArea())
    }
}
