//
//  MinterInfoScreen.swift
//  CryptoInsta
//
//  Created by Lev Baklanov on 17.07.2022.
//

import SwiftUI
import BigInt

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
                    .padding(.bottom, 4)
                Spacer()
            }
            
            ScrollView(showsIndicators: true) {
                VStack(spacing: 0) {
                    
                    Text("How to earn")
                        .foregroundColor(Colors.darkGrey)
                        .font(.custom("rubik-bold", fixedSize: 28))
                        .padding(.top, 20)
                        .padding(.horizontal, 10)
                    
                    Text("Minter Guru (MIGU) tokens")
                        .foregroundColor(Colors.mainGrey)
                        .multilineTextAlignment(.center)
                        .font(.custom("rubik-bold", fixedSize: 19))
                        .padding(.top, 10)
                        .padding(.horizontal, 10)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Ways to get MIGU tokens")
                            .foregroundColor(Colors.darkGrey)
                            .font(.custom("rubik-bold", fixedSize: 17))
                        
                        Text("You can earn our tokens for your activity on Twitter. To receive rewards, you need to link your Twitter account in the input field below.")
                            .foregroundColor(Colors.darkGrey)
                            .font(.custom("rubik-regular", fixedSize: 17))
                        
                        if let info = globalVm.twitterFollowInfo, globalVm.twitterFollowRewardReceived || (info.open && info.spent < info.limit) {
                        
                            VStack(alignment: .leading, spacing: 0) {
                                HStack(spacing: 0) {
                                    Text("- Follow us on ")
                                        .foregroundColor(Colors.darkGrey)
                                        .font(.custom("rubik-regular", fixedSize: 17))
                                    
                                    Button {
                                        if !globalVm.twitterFollowRewardReceived {
                                            globalVm.applyForFollowReward()
                                        }
                                        if let url = URL(string: Constants.minterTwitterLink),
                                           UIApplication.shared.canOpenURL(url) {
                                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                        } else {
                                            //TODO: handle error
                                        }
                                    } label: {
                                        Text("Twitter")
                                            .foregroundColor(Colors.mainPurple)
                                            .font(.custom("rubik-bold", fixedSize: 17))
                                    }
                                    
                                    if globalVm.twitterFollowRewardReceived {
                                        Text(" (+)")
                                            .foregroundColor(Colors.darkGrey)
                                            .font(.custom("rubik-regular", fixedSize: 17))
                                    }
                                }
                                
                                Text("•  reward - \(Tools.formatUint256(BigUInt(info.value)!, decimals: 0)) MIGU")
                                    .foregroundColor(Colors.darkGrey)
                                    .font(.custom("rubik-regular", fixedSize: 17))
                                    .padding(.leading, 20)
                                Text("•  one time only")
                                    .foregroundColor(Colors.darkGrey)
                                    .font(.custom("rubik-regular", fixedSize: 17))
                                    .padding(.leading, 20)
                            }
                        }
                        
                        if let info = globalVm.twitterInfo {
                            VStack(alignment: .leading, spacing: 0) {
                                let rewardsCount = globalVm.rewards?.count ?? 0
                                let totalLimit = info.personalTotalLimit
                                let addition = rewardsCount >= info.personalTotalLimit ? "(done \(totalLimit)/\(totalLimit))" :
                                (info.spent >= info.limit ? "" : "(done \(rewardsCount)/\(totalLimit))")
                                
                                Text("- Share your photos on Twitter \(addition)")
                                    .foregroundColor(Colors.darkGrey)
                                    .font(.custom("rubik-regular", fixedSize: 17))
                                
                                Text("•  reward - \(Tools.formatUint256(BigUInt(info.value)!, decimals: 0)) MIGU per post")
                                    .foregroundColor(Colors.darkGrey)
                                    .font(.custom("rubik-regular", fixedSize: 17))
                                    .padding(.leading, 20)
                                
                                Text("•  up to \(info.personalLimit) rewards per day")
                                    .foregroundColor(Colors.darkGrey)
                                    .font(.custom("rubik-regular", fixedSize: 17))
                                    .padding(.leading, 20)
                                
                                Text("•  total \(info.personalTotalLimit) rewards limit")
                                    .foregroundColor(Colors.darkGrey)
                                    .font(.custom("rubik-regular", fixedSize: 17))
                                    .padding(.leading, 20)
                            }
                            
                            Text("Tokens will be sent 24 hours after the post is published.")
                                .foregroundColor(Colors.darkGrey)
                                .font(.custom("rubik-regular", fixedSize: 17))
                            
                            Text("The post must contain the \(Constants.minterHashtag) hashtag to earn tokens.")
                                .foregroundColor(Colors.darkGrey)
                                .font(.custom("rubik-semibold", fixedSize: 17))
                        }
                        
//                        if let twitterInfo = globalVm.twitterInfo, let rewards = globalVm.rewards {
//                            RepostsInfo(info: twitterInfo, rewards: rewards)
//                                .padding(.top, 20)
//                        }
                    }
                    .padding(20)
                    .background(Colors.mainWhite)
                    .cornerRadius(30, corners: [.topLeft, .bottomRight])
                    .cornerRadius(10, corners: [.bottomLeft, .topRight])
                    .shadow(color: Colors.darkGrey.opacity(0.25), radius: 10, x: 0, y: 0)
                    .padding(.top, 25)
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
                        .font(.custom("rubik-bold", fixedSize: 17))
                        .placeholder(when: twitterName.isEmpty) {
                            HStack {
                                Text("Enter your twitter nickname")
                                    .font(.custom("rubik-bold", fixedSize: 17))
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
                        .padding(.horizontal, 26)
                        .padding(.top, 25)
                    
                    Button {
                        twitterName = twitterName.trimmingCharacters(in: .whitespacesAndNewlines)
                        let res = Tools.parseTwitter(twitter: twitterName)
                        hideKeyboard()
                        if res.valid {
                            UserDefaultsWorker.shared.saveTwitterLogin(token: res.login)
                            twitterName = res.login
                            alert = IdentifiableAlert.build(
                                id: "twitter_saved",
                                title: "Saved",
                                message: "Your twitter nickname was successfully saved"
                            )
                        } else {
                            alert = IdentifiableAlert.build(
                                id: "invalid_twitter",
                                title: "Invalid twitter nickname",
                                message: "Please enter your valid twitter nickname with or without @"
                            )
                        }
                    } label: {
                        Text("Save")
                            .font(.custom("rubik-bold", fixedSize: 17))
                            .foregroundColor(Colors.mainWhite)
                            .padding(.vertical, 17)
                            .padding(.horizontal, 60)
                            .background(Colors.mainGradient)
                            .cornerRadius(32)
                            .shadow(color: Colors.mainGrey.opacity(0.15), radius: 20, x: 0, y: 0)
                    }
                    .padding(.top, 25)
                    
                    Tip(text: "The ways of obtaining tokens can be changed or expanded over time.\nStay tuned for updates!")
                        .padding(.top, 25)
                        .padding(.horizontal, 26)
                        .padding(.bottom, 40)
                    
                    Spacer()
                }
            }
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
                            .font(.custom("rubik-bold", fixedSize: 16))
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
                                .font(.custom("rubik-regular", fixedSize: 16))
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
                            .font(.custom("rubik-bold", fixedSize: 16))
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
                                .font(.custom("rubik-regular", fixedSize: 16))
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
