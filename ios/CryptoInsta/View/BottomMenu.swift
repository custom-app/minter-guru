//
//  BottomMenu.swift
//  CryptoInsta
//
//  Created by Lev Baklanov on 01.06.2022.
//

import SwiftUI

enum TabItem {
    case wallet
    case mint
    case gallery
}

struct BottomMenu: View {
    
    @EnvironmentObject
    var globalVm: GlobalViewModel
    
    
    var body: some View {
        HStack(spacing: 0) {
            HStack {
                Spacer()
                Text("Wallet")
                    .font(.system(size: 16))
                    .foregroundColor(.black.opacity(globalVm.currentTab == .wallet ? 1 : 0.5))
                Spacer()
            }
            .padding(.vertical, 12)
            .background(Color.black.opacity(globalVm.currentTab == .wallet ? 0 : 0.1))
            .onTapGesture {
                withAnimation {
                    globalVm.currentTab = .wallet
                }
            }
            
            HStack {
                Spacer()
                Text("Mint")
                    .font(.system(size: 16))
                    .foregroundColor(.black.opacity(globalVm.currentTab == .mint ? 1 : 0.5))
                Spacer()
            }
            .padding(.vertical, 12)
            .background(Color.black.opacity(globalVm.currentTab == .mint ? 0 : 0.1))
            .onTapGesture {
                withAnimation {
                    globalVm.currentTab = .mint
                }
            }
            
            HStack {
                Spacer()
                Text("Gallery")
                    .font(.system(size: 16))
                    .foregroundColor(.black.opacity(globalVm.currentTab == .gallery ? 1 : 0.5))
                Spacer()
            }
            .padding(.vertical, 12)
            .background(Color.black.opacity(globalVm.currentTab == .gallery ? 0 : 0.1))
            .onTapGesture {
                withAnimation {
                    globalVm.currentTab = .gallery
                }
            }
        }
    }
}

struct BottomMenu_Previews: PreviewProvider {
    static var previews: some View {
        BottomMenu()
    }
}
