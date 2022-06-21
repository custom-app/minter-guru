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
            Spacer()
            HStack(spacing: 0) {
                ZStack {
                    ZStack {
                        Image("ic_wallet")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(globalVm.currentTab == .wallet ? Colors.mainWhite : Colors.darkGrey)
                            .frame(width: 20.2, height: 17.4)
                    }
                    .frame(width: 80, height: 30)
                    .background(globalVm.currentTab == .wallet ? Colors.mainGreen : Colors.mainWhite)
                    .cornerRadius(30)
                    .shadow(color: Colors.mainGreen.opacity(globalVm.currentTab == .wallet ? 0.8 : 0), radius: 3, x: 0, y: 0)
                }
                .frame(width: 90, height: 40)
                .background(Colors.mainWhite)
                .cornerRadius(30, corners: [.topLeft, .bottomLeft])
                .onTapGesture {
                    withAnimation {
                        globalVm.currentTab = .wallet
                    }
                }
                

                ZStack {
                    Rectangle()
                        .fill(Colors.mainWhite)
                        .frame(width: 90, height: 40)

                    ZStack {
                        Image("ic_mint_rect")
                            .renderingMode(.template)
                            .resizable()
                            .foregroundColor(globalVm.currentTab == .mint ? Colors.mainGreen : Colors.mainWhite)
                            .frame(width: 61, height: 67)
                        
                        Image("ic_plus")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(globalVm.currentTab == .mint ? Colors.mainWhite : Colors.darkGrey)
                            .frame(width: 27.3, height: 27)
                    }
                    .compositingGroup()
                    .shadow(color: Colors.mainGreen.opacity(globalVm.currentTab == .mint ? 0.7 : 0), radius: 5, x: 0, y: 0)
                }
                .onTapGesture {
                    withAnimation {
                        globalVm.currentTab = .mint
                    }
                }

                ZStack {
                    ZStack {
                        Image("ic_gallery")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(globalVm.currentTab == .gallery ? Colors.mainWhite : Colors.darkGrey)
                            .frame(width: 22, height: 22)
                    }
                    .frame(width: 80, height: 30)
                    .background(globalVm.currentTab == .gallery ? Colors.mainGreen : Colors.mainWhite)
                    .cornerRadius(30)
                    .shadow(color: Colors.mainGreen.opacity(globalVm.currentTab == .gallery ? 0.8 : 0), radius: 3, x: 0, y: 0)
                }
                .frame(width: 90, height: 40)
                .background(Colors.mainWhite)
                .cornerRadius(30, corners: [.topRight, .bottomRight])
                .onTapGesture {
                    withAnimation {
                        globalVm.currentTab = .gallery
                    }
                }
            }
            .compositingGroup()
            .shadow(color: Colors.mainBlack.opacity(0.15), radius: 5)
            
            Spacer()
        }
    }
}

struct BottomMenu_Previews: PreviewProvider {
    static var previews: some View {
        BottomMenu()
    }
}
