//
//  AuthContainer.swift
//  CryptoInsta
//
//  Created by Lev Baklanov on 01.06.2022.
//

import SwiftUI

struct AuthContainer: View {
    
    @EnvironmentObject
    var globalVm: GlobalViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            if globalVm.session == nil {
                Button {
                    globalVm.showConnectSheet = true
                } label: {
                    Text("Connect")
                        .font(.system(size: 17))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 15)
                        .background(Colors.polygonPurple)
                        .cornerRadius(32)
                }
                .padding(.top, 24)
            } else {
                Button {
                    globalVm.disconnect()
                } label: {
                    HStack {
                        Spacer()
                        Text("Disconnect")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(Color.green)
                        Spacer()
                    }
                    .padding(.vertical, 15)
                    .background(Color.white)
                    .cornerRadius(32)
                    .overlay(
                        RoundedRectangle(cornerRadius: 32)
                            .stroke(Color.green, lineWidth: 2)
                    )
                }
                .padding(.horizontal, 30)
                .padding(.top, 30)
            }
            Spacer()
        }
        .sheet(isPresented: $globalVm.showConnectSheet) {
            ConnectSheet()
                .environmentObject(globalVm)
        }
    }
}

