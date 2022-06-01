//
//  ContentView.swift
//  CryptoInsta
//
//  Created by Lev Baklanov on 30.05.2022.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject
    var globalVm = GlobalViewModel()
    
    var body: some View {
        NavigationView {
            MainContainer()
                .navigationTitle("")
                .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .environmentObject(globalVm)
        .onAppear {
            print("content view on appear")
            // init wallet connect here
        }
    }
}
