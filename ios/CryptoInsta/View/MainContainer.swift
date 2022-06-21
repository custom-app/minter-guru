//
//  MainContainer.swift
//  CryptoInsta
//
//  Created by Lev Baklanov on 01.06.2022.
//

import SwiftUI

struct MainContainer: View {
    
    @EnvironmentObject
    var globalVm: GlobalViewModel
    
    var body: some View {
        ZStack {
            switch globalVm.currentTab {
            case .wallet:
                AuthContainer()
            case .mint:
                MintContainer()
            case .gallery:
                GalleryContainer()
            }
            
            BottomMenu()
        }
        .background(Colors.mainWhite.ignoresSafeArea())
        .alert(item: $globalVm.alert) { alert in
            alert.alert()
        }
    }
}
