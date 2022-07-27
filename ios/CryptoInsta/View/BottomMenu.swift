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
        GeometryReader { geometry in
            let width = geometry.size.width
            VStack {
                Spacer()
                HStack(spacing: 0) {
                    Spacer()
                    HStack(spacing: 0) {
                        ZStack {
                            ZStack {
                                Image("ic_wallet")
                                    .resizable()
                                    .renderingMode(.template)
                                    .foregroundColor(globalVm.currentTab == .wallet ? Colors.mainWhite : Colors.mainGrey)
                                    .frame(width: 0.054*width, height: 0.0464*width)
                            }
                            .frame(width: 0.213*width, height: 0.08*width)
                            .background(globalVm.currentTab == .wallet ? Colors.mainPurple : Colors.mainWhite)
                            .cornerRadius(30)
                            .shadow(color: Colors.mainPurple.opacity(globalVm.currentTab == .wallet ? 0.8 : 0), radius: 3, x: 0, y: 0)
                        }
                        .frame(width: 0.24*width, height: 0.107*width)
                        .background(Colors.mainWhite)
                        .cornerRadius(30, corners: [.topLeft, .bottomLeft])
                        .onTapGesture {
                            globalVm.vibrationWorker?.vibrate()
                            withAnimation {
                                globalVm.currentTab = .wallet
                            }
                        }
                        

                        ZStack {
                            Rectangle()
                                .fill(Colors.mainWhite)
                                .frame(width: 0.24*width, height: 0.107*width)

                            ZStack {
                                Image("ic_mint_rect")
                                    .renderingMode(.template)
                                    .resizable()
                                    .foregroundColor(globalVm.currentTab == .mint ? Colors.mainPurple : Colors.mainWhite)
                                    .frame(width: 0.163*width, height: 0.179*width)
                                
                                Image("ic_plus")
                                    .resizable()
                                    .renderingMode(.template)
                                    .foregroundColor(globalVm.currentTab == .mint ? Colors.mainWhite : Colors.mainGrey)
                                    .frame(width: 0.0728*width, height: 0.072*width)
                            }
                            .compositingGroup()
                            .shadow(color: Colors.mainPurple.opacity(globalVm.currentTab == .mint ? 0.7 : 0), radius: 5, x: 0, y: 0)
                        }
                        .onTapGesture {
                            globalVm.vibrationWorker?.vibrate()
                            withAnimation {
                                globalVm.currentTab = .mint
                            }
                        }

                        ZStack {
                            ZStack {
                                Image("ic_gallery")
                                    .resizable()
                                    .renderingMode(.template)
                                    .foregroundColor(globalVm.currentTab == .gallery ? Colors.mainWhite : Colors.mainGrey)
                                    .frame(width: 0.059*width, height: 0.059*width)
                            }
                            .frame(width: 0.213*width, height: 0.08*width)
                            .background(globalVm.currentTab == .gallery ? Colors.mainPurple : Colors.mainWhite)
                            .cornerRadius(30)
                            .shadow(color: Colors.mainPurple.opacity(globalVm.currentTab == .gallery ? 0.8 : 0), radius: 3, x: 0, y: 0)
                        }
                        .frame(width: 0.24*width, height: 0.107*width)
                        .background(Colors.mainWhite)
                        .cornerRadius(30, corners: [.topRight, .bottomRight])
                        .onTapGesture {
                            globalVm.vibrationWorker?.vibrate()
                            withAnimation {
                                globalVm.currentTab = .gallery
                            }
                        }
                    }
                    .compositingGroup()
                    .shadow(color: Colors.darkGrey.opacity(0.15), radius: 5)
                    
                    Spacer()
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
