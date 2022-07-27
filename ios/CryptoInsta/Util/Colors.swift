//
//  Colors.swift
//  CryptoInsta
//
//  Created by Lev Baklanov on 01.06.2022.
//

import Foundation

import SwiftUI

class Colors {

    static var polygonPurple: Color {
        Color(hex: "#8247E5")
    }
    
    static var mainGrey: Color {
        Color(hex: "#8992A9")
    }
    
    static var lightGrey: Color {
        Color(hex: "#EAEAEA")
    }
    
    static var darkGrey: Color {
        Color(hex: "#454C5F")
    }
    
    static var greyBlue: Color {
        Color(hex: "#67728E")
    }
    
    static var mainWhite: Color {
        Color(hex: "#F8F8F8")
    }
    
    static var whiteBackground: Color {
        Color(hex: "#F2F3F2")
    }
    
    static var mainPurple: Color {
        Color(hex: "#6E53C3")
    }
    
    static var palePurple: Color {
        Color(hex: "#EAE3FF")
    }
    
    static var brightGreen: Color {
        Color(hex: "#5DDE6A")
    }
    
    static var brightBlue: Color {
        Color(hex: "#63AFD0")
    }
    
    static var paleRed: Color {
        Color(hex: "#FCE4E4")
    }
    
    
    static var mainGradient: LinearGradient {
        LinearGradient(colors: [Colors.brightGreen, Colors.brightBlue, Colors.mainPurple],
                                   startPoint: .leading,
                                   endPoint: .trailing)
    }
}
