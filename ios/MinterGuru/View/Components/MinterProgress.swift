//
//  MinterProgress.swift
//  CryptoInsta
//
//  Created by Lev Baklanov on 27.07.2022.
//

import SwiftUI

struct MinterProgress: View {
    @State
    var angle: Double = 0.0
    @State
    var isAnimating = false
    
    let height: Double = 56
    
    var foreverAnimation: Animation {
        Animation.easeInOut(duration: 0.9)
            .repeatForever(autoreverses: true)
    }
    
    var body: some View {
        Image("ic_logo_v0")
            .resizable()
            .scaledToFit()
            .frame(height: height)
            .opacity(isAnimating ? 0.4 : 1)
            .offset(x: 0, y: isAnimating ? -10 : 10)
            .animation(foreverAnimation, value: isAnimating)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                    isAnimating = true
                }
            }
    }
}

struct MinterProgress_Previews: PreviewProvider {
    static var previews: some View {
        MinterProgress()
    }
}
