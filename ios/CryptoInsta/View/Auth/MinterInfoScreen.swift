//
//  MinterInfoScreen.swift
//  CryptoInsta
//
//  Created by Lev Baklanov on 17.07.2022.
//

import SwiftUI

struct MinterInfoScreen: View {
    
    @EnvironmentObject
    var globalVm: GlobalViewModel
    
    @State
    var twitterName: String = UserDefaultsWorker.shared.getTwitterLogin()
    
    @State
    var alert: IdentifiableAlert?
    
    var body: some View {
        VStack(spacing: 0) {
            
            HStack {
                Spacer()
                SheetStroke()
                Spacer()
            }
            
            Text("How to earn")
                .foregroundColor(Colors.darkGrey)
                .font(.custom("rubik-bold", size: 28))
                .padding(.top, 26)
                .padding(.horizontal, 10)
            
            Text("Minter Guru tokens")
                .foregroundColor(Colors.mainGrey)
                .multilineTextAlignment(.center)
                .font(.custom("rubik-bold", size: 19))
                .padding(.top, 10)
                .padding(.horizontal, 10)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Ways to get tokens")
                    .foregroundColor(Colors.darkGrey)
                    .font(.custom("rubik-bold", size: 17))
                
                Text("-You can get tokens for sharing your photos on twitter")
                    .foregroundColor(Colors.darkGrey)
                    .font(.custom("rubik-regular", size: 17))
                
                Text("Just link your twitter below and share photos. Tokens will be sent 24 hours after publication")
                    .foregroundColor(Colors.darkGrey)
                    .font(.custom("rubik-regular", size: 17))
                    .padding(.top, 12)
                
                if let twitterInfo = globalVm.twitterInfo, let rewards = globalVm.rewards {
                    RepostsInfo(info: twitterInfo, rewards: rewards)
                        .padding(.top, 20)
                }
            }
            .padding(20)
            .background(Colors.mainWhite)
            .cornerRadius(30, corners: [.topLeft, .bottomRight])
            .cornerRadius(10, corners: [.bottomLeft, .topRight])
            .shadow(color: Colors.darkGrey.opacity(0.25), radius: 10, x: 0, y: 0)
            .padding(.top, 50)
            .padding(.horizontal, 26)
            
            if let info = globalVm.twitterInfo, !info.open || info.spent == info.limit {
                if !info.open {
                    Tip(text: "The issuance of tokens for tweets is temporarily suspended",
                        backgroundColor: Colors.paleRed)
                    .padding(.top, 25)
                    .padding(.horizontal, 26)
                } else {
                    Tip(text: "Total tweet reward limit reached for today",
                        backgroundColor: Colors.paleRed)
                    .padding(.top, 25)
                    .padding(.horizontal, 26)
                }
            }
            
            TextField("", text: $twitterName)
                .keyboardType(.twitter)
                .font(.custom("rubik-bold", size: 17))
                .placeholder(when: twitterName.isEmpty) {
                 HStack {
                     Text("Enter your twitter nickname")
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
                .padding(.trailing, 35)
                .background(Colors.mainWhite)
                .cornerRadius(32)
                .overlay(
                 RoundedRectangle(cornerRadius: 32)
                     .stroke(Colors.mainPurple, lineWidth: 2)
                )
                .overlay(
                 HStack {
                     Spacer()
                     Button {
                         twitterName = twitterName.trimmingCharacters(in: .whitespacesAndNewlines)
                         let res = Tools.parseTwitter(twitter: twitterName)
                         if res.valid {
                             UserDefaultsWorker.shared.saveTwitterLogin(token: res.login)
                             twitterName = res.login
                             hideKeyboard()
                         } else {
                             alert = IdentifiableAlert.build(
                                 id: "invalid_twitter",
                                 title: "Invalid twitter nickname",
                                 message: "Please enter your valid twitter nickname with or without @"
                             )
                         }
                     } label: {
                         Image("ic_ok_light")
                             .renderingMode(.template)
                             .resizable()
                             .scaledToFit()
                             .foregroundColor(twitterName.isEmpty ? Colors.mainGrey : Colors.mainPurple)
                             .frame(width: 24, height: 24)
                     }
                     .padding(.trailing, 16)
                     .disabled(twitterName.isEmpty)
                 }
                )
                .padding(.horizontal, 26)
                .padding(.top, 25)
            
            Spacer()
        }
        .background(Colors.mainWhite.ignoresSafeArea())
        .alert(item: $alert) { alert in
            alert.alert()
        }
    }
}

struct RepostsInfo: View {
    
    let info: TwitterInfo
    let rewards: [RewardInfo]
    
    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Colors.lightGrey)
                .frame(height: 1)

            HStack(spacing: 0) {

                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text("Earned today:")
                            .foregroundColor(Colors.darkGrey)
                            .font(.custom("rubik-bold", size: 16))
                        Spacer()
                    }
                    HStack(spacing: 0) {
                        HStack(spacing: 0) {
                            Image("ic_migu_token")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 15, height: 15)

                            Text(String(Tools.calcTodayRewards(rewards: rewards)))
                                .foregroundColor(Colors.darkGrey)
                                .font(.custom("rubik-regular", size: 16))
                                .padding(.leading, 5)
                        }
                        Spacer()
                    }
                    .padding(.leading, 2)
                }
                .frame(maxWidth: .infinity)

                Rectangle()
                    .fill(Colors.lightGrey)
                    .frame(width: 1, height: 46)

                VStack(spacing: 0) {
                    HStack {
                        Text("Daily limit:")
                            .foregroundColor(Colors.mainGrey)
                            .font(.custom("rubik-bold", size: 16))
                        Spacer()
                    }
                    HStack(spacing: 0) {
                        HStack(spacing: 0) {
                            Image("ic_migu_token")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 15, height: 15)

                            Text(String(info.personalLimit))
                                .foregroundColor(Colors.mainGrey)
                                .font(.custom("rubik-regular", size: 16))
                                .padding(.leading, 5)
                        }
                        Spacer()
                    }
                    .padding(.leading, 2)
                }
                .frame(maxWidth: .infinity)
                .padding(.leading, 25)
            }
            .padding(.top,  8)
        }
    }
}

struct MinterInfoScreen_Previews: PreviewProvider {
    static var previews: some View {
        MinterInfoScreen()
    }
}
