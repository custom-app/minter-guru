//
//  AddressAuthSheet.swift
//  MinterGuru
//
//  Created by Lev Baklanov on 17.08.2022.
//

import Foundation
import SwiftUI


struct AddressAuthSheet: View {
    
    @EnvironmentObject
    var globalVm: GlobalViewModel
    
    @Binding
    var showSheet: Bool
    
    @State
    var address = ""
    
    @State
    var alert: IdentifiableAlert?
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                SheetStroke()
                    .padding(.bottom, 4)
                Spacer()
            }
            
            Text("Auth through wallet address")
                .foregroundColor(Colors.darkGrey)
                .font(.custom("rubik-bold", size: 28))
                .multilineTextAlignment(.center)
                .padding(.top, 26)
                .padding(.horizontal, 30)
            
            Text("Enter your address")
                .foregroundColor(Colors.mainGrey)
                .font(.custom("rubik-bold", size: 24))
                .padding(.top, 25)
                .padding(.horizontal, 10)
            
            TextField("", text: $address)
                .font(.custom("rubik-bold", size: 17))
                .placeholder(when: address.isEmpty) {
                    HStack {
                        Text("0x.......")
                            .font(.custom("rubik-bold", size: 17))
                            .foregroundColor(Colors.mainGrey)
                        Spacer()
                    }
                }
                .foregroundColor(Colors.darkGrey)
                .lineLimit(1)
                .truncationMode(.tail)
                .padding(.horizontal, 14)
                .padding(.vertical, 13)
                .background(Colors.mainWhite)
                .cornerRadius(32)
                .overlay(
                    RoundedRectangle(cornerRadius: 32)
                        .stroke(Colors.mainPurple, lineWidth: 2)
                )
                .padding(.horizontal, 26)
                .padding(.top, 50)
            
            Button {
                hideKeyboard()
                if Tools.isAddressValid(address) {
                    globalVm.authByAddress(address)
                    showSheet = false
                } else {
                    alert = IdentifiableAlert.build(
                        id: "invalid_address",
                        title: "Invalid address",
                        message: "Please enter valid wallet address starting with 0x"
                    )
                }
            } label: {
                Text("Authorize")
                    .font(.custom("rubik-bold", size: 17))
                    .foregroundColor(Colors.mainWhite)
                    .padding(.vertical, 17)
                    .padding(.horizontal, 40)
                    .background(Colors.mainGradient)
                    .cornerRadius(32)
                    .shadow(color: Colors.mainGrey.opacity(0.15), radius: 20, x: 0, y: 0)
            }
            .padding(.top, 25)
            
            Tip(text: "We recommend to authorize through wallet connection. With address authorization some functionality might be not available",
                backgroundColor: Colors.paleRed)
            .padding(.horizontal, 26)
            .padding(.vertical, 50)
            .ignoresSafeArea(.keyboard)
            
            Spacer()
        }
        .background(Colors.whiteBackground.ignoresSafeArea())
        .alert(item: $alert) { alert in
            alert.alert()
        }
    }
}
