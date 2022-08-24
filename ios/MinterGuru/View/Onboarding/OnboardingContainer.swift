//
//  OnboardingContainer.swift
//  MinterGuru
//
//  Created by Lev Baklanov on 18.08.2022.
//

import SwiftUI

struct OnboardingContainer: View {
    
    @EnvironmentObject
    var globalVm: GlobalViewModel
    
    @State
    var state: OnboardingState = .first
    
    @State
    var isAnimating = false
    
    var rotateAnimation: Animation {
        Animation.linear(duration: 16.0)
            .repeatForever(autoreverses: false)
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                
                OnboardingTitle(state: $state)
                    .padding(.horizontal, 25)
                    .animation(.easeInOut(duration: 1), value: state)
                
                OnboardingStatePanel(state: $state)
                    .padding(.top, 25)
                    .padding(.horizontal, 25)
                
                HStack {
                    switch state {
                    case .first:
                        Text("You enter the temple and see a monk in front of you")
                            .font(.custom("rubik-semibold", size: 20))
                            .foregroundColor(Color.white)
                            .multilineTextAlignment(.leading)
                            .transition(.backslide.combined(with: .opacity))
                    case .second:
                        Text("In front of your eyes, a guru turns a photo into an NFT")
                            .font(.custom("rubik-semibold", size: 20))
                            .foregroundColor(Color.white)
                            .multilineTextAlignment(.leading)
                            .transition(.backslide.combined(with: .opacity))
                    case .third:
                        Text("The Guru has chosen you and gave you a great mission")
                            .font(.custom("rubik-semibold", size: 20))
                            .foregroundColor(Color.white)
                            .multilineTextAlignment(.leading)
                            .transition(.backslide.combined(with: .opacity))
                    case .fourth:
                        Text("To become a Guru a hero must own a smartcontract")
                            .font(.custom("rubik-semibold", size: 20))
                            .foregroundColor(Color.white)
                            .multilineTextAlignment(.leading)
                            .transition(.backslide.combined(with: .opacity))
                    case .fifth:
                        Text("The Access Token is your key to the smartcontract ownership")
                            .font(.custom("rubik-semibold", size: 20))
                            .foregroundColor(Color.white)
                            .multilineTextAlignment(.leading)
                            .transition(.backslide.combined(with: .opacity))
                    }
                    Spacer()
                }
                .padding(.leading, 25)
                .padding(.trailing, 20)
                .padding(.top, 25)
                .animation(.easeInOut(duration: 1), value: state)
                
                
                ZStack {
                    switch state {
                    case .first:
                        ZStack {
                            Image("onboarding_rotating_1")
                                .resizable()
                                .scaledToFit()
                                .frame(width: geometry.size.width * 2/3, height: geometry.size.width * 2/3)
                                .rotationEffect(Angle.degrees(isAnimating ? 360 : 0))
                                .animation(rotateAnimation,
                                           value: isAnimating)

                            Image("onboarding_center_1")
                                .resizable()
                                .scaledToFit()
                                .frame(width: geometry.size.width * 0.48, height: geometry.size.width * 0.48)
                                .shadow(color: Colors.brightGreen.opacity(0.25), radius: 50, x: 0, y: 0)

                            Circle()
                                .fill(
                                    RadialGradient(colors: [Colors.brightBlue.opacity(0.4), Colors.brightBlue.opacity(0)],
                                                   center: .center,
                                                   startRadius: 0,
                                                   endRadius: 0.25*geometry.size.width)
                            )
                            .frame(width: 0.53*geometry.size.width, height: 0.53*geometry.size.width)
                        }
                        .transition(.backslide.combined(with: .opacity))
                        .onAppear {
                            withAnimation {
                                isAnimating.toggle()
                            }
                        }
                    case .second:
                        ZStack {
                            Image("onboarding_rotating_2")
                                .resizable()
                                .scaledToFit()
                                .frame(width: geometry.size.width * 2/3, height: geometry.size.width * 2/3)
                                .rotationEffect(Angle.degrees(isAnimating ? 360 : 0))
                                .animation(rotateAnimation,
                                           value: isAnimating)

                            Image("onboarding_center_2")
                                .resizable()
                                .scaledToFit()
                                .frame(width: geometry.size.width * 0.48, height: geometry.size.width * 0.48)
                                .shadow(color: Colors.brightBlue.opacity(0.5), radius: 50, x: 0, y: 0)

                            Circle()
                                .fill(
                                    RadialGradient(colors: [Colors.brightPurple.opacity(0.5), Colors.brightBlue.opacity(0)],
                                                   center: .center,
                                                   startRadius: 0,
                                                   endRadius: 0.25*geometry.size.width)
                            )
                            .frame(width: 0.53*geometry.size.width, height: 0.53*geometry.size.width)
                        }
                        .transition(.backslide.combined(with: .opacity))
                        .onAppear {
                            isAnimating.toggle()
                        }
                    case .third:
                        ZStack {
                            Image("onboarding_rotating_3")
                                .resizable()
                                .scaledToFit()
                                .frame(width: geometry.size.width * 2/3, height: geometry.size.width * 2/3)
                                .rotationEffect(Angle.degrees(isAnimating ? 360 : 0))
                                .animation(rotateAnimation,
                                           value: isAnimating)

                            Image("onboarding_center_3")
                                .resizable()
                                .scaledToFit()
                                .frame(width: geometry.size.width * 0.48, height: geometry.size.width * 0.48)
                                .shadow(color: Colors.brightGreen.opacity(0.25), radius: 50, x: 0, y: 0)

                            Circle()
                                .fill(
                                    RadialGradient(colors: [Colors.brightBlue.opacity(0.4), Colors.brightBlue.opacity(0)],
                                                   center: .center,
                                                   startRadius: 0,
                                                   endRadius: 0.25*geometry.size.width)
                            )
                            .frame(width: 0.53*geometry.size.width, height: 0.53*geometry.size.width)
                        }
                        .transition(.backslide.combined(with: .opacity))
                        .onAppear {
                            isAnimating.toggle()
                        }
                    case .fourth:
                        ZStack {
                            Image("onboarding_rotating_4")
                                .resizable()
                                .scaledToFit()
                                .frame(width: geometry.size.width * 2/3, height: geometry.size.width * 2/3)
                                .rotationEffect(Angle.degrees(isAnimating ? 360 : 0))
                                .animation(rotateAnimation,
                                           value: isAnimating)

                            Image("onboarding_center_4")
                                .resizable()
                                .scaledToFit()
                                .frame(width: geometry.size.width * 0.48, height: geometry.size.width * 0.48)
                                .shadow(color: Colors.brightBlue.opacity(0.5), radius: 50, x: 0, y: 0)

                            Circle()
                                .fill(
                                    RadialGradient(colors: [Colors.brightPurple.opacity(0.5), Colors.brightBlue.opacity(0)],
                                                   center: .center,
                                                   startRadius: 0,
                                                   endRadius: 0.25*geometry.size.width)
                            )
                            .frame(width: 0.53*geometry.size.width, height: 0.53*geometry.size.width)
                        }
                        .transition(.backslide.combined(with: .opacity))
                        .onAppear {
                            isAnimating.toggle()
                        }
                    case .fifth:
                        ZStack {
                            Image("onboarding_rotating_5")
                                .resizable()
                                .scaledToFit()
                                .frame(width: geometry.size.width * 2/3, height: geometry.size.width * 2/3)
                                .rotationEffect(Angle.degrees(isAnimating ? 360 : 0))
                                .animation(rotateAnimation,
                                           value: isAnimating)

                            Image("onboarding_center_5")
                                .resizable()
                                .scaledToFit()
                                .frame(width: geometry.size.width * 0.48, height: geometry.size.width * 0.48)
                                .shadow(color: Colors.brightPurple.opacity(0.5), radius: 50, x: 0, y: 0)

                            Circle()
                                .fill(
                                    RadialGradient(colors: [Colors.brightBlue.opacity(0.4), Colors.brightBlue.opacity(0)],
                                                   center: .center,
                                                   startRadius: 0,
                                                   endRadius: 0.25*geometry.size.width)
                            )
                            .frame(width: 0.53*geometry.size.width, height: 0.53*geometry.size.width)
                        }
                        .transition(.backslide.combined(with: .opacity))
                        .onAppear {
                            isAnimating.toggle()
                        }
                    }
                    
                }
                .padding(.top, 50)
                .animation(.easeInOut(duration: 1), value: state)
                
                HStack {
                    switch state {
                    case .first:
                        AttributedText(attributedString: AttributedStringWorker.shared.onboardingFirst)
                            .blendMode(.hardLight)
                            .transition(.backslide.combined(with: .opacity))
                    case .second:
                        AttributedText(attributedString: AttributedStringWorker.shared.onboardingSecond)
                            .blendMode(.hardLight)
                            .transition(.backslide.combined(with: .opacity))
                    case .third:
                        AttributedText(attributedString: AttributedStringWorker.shared.onboardingThird)
                            .blendMode(.hardLight)
                            .transition(.backslide.combined(with: .opacity))
                    case .fourth:
                        AttributedText(attributedString: AttributedStringWorker.shared.onboardingFourth)
                            .blendMode(.hardLight)
                            .transition(.backslide.combined(with: .opacity))
                    case .fifth:
                        AttributedText(attributedString: AttributedStringWorker.shared.onboardingFifth)
                            .blendMode(.hardLight)
                            .transition(.backslide.combined(with: .opacity))
                    }
                }
                .padding(.leading, 25)
                .padding(.trailing, 20)
                .padding(.top, 16)
                .animation(.easeInOut(duration: 1), value: state)
                
                Spacer()
                
                HStack(spacing: 0) {
                    Button {
                        if state == .first {
                            UserDefaultsWorker.shared.setOnBoardingShown(shown: true)
                            withAnimation {
                                globalVm.showingOnboarding = false
                            }
                        } else {
                            if let newState = OnboardingState(rawValue: state.rawValue-1) {
                                withAnimation {
                                    state = newState
                                }
                            }
                        }
                    } label: {
                        Text(state == .first ? "skip >>" : "< back")
                            .font(.custom("rubik-semibold", size: 20))
                            .foregroundColor(Color.white.opacity(0.25))
                    }
                    .frame(maxWidth: .infinity)
                    
                    Button {
                        if state == .fifth {
                            UserDefaultsWorker.shared.setOnBoardingShown(shown: true)
                            withAnimation {
                                globalVm.showingOnboarding = false
                            }
                        } else {
                            if let newState = OnboardingState(rawValue: state.rawValue+1) {
                                withAnimation {
                                    state = newState
                                }
                            }
                        }
                    } label: {
                        ZStack {
                            if state == .fifth {
                                LinearGradient(colors: [Colors.brightGreen, Colors.brightBlue, Colors.brightPurple],
                                               startPoint: .bottomLeading,
                                               endPoint: .topTrailing)
                                    .mask (
                                        Text(state.nextText())
                                            .font(.custom("rubik-semibold", size: 20))
                                            .foregroundColor(Color.white)
                                    )
                                    .frame(width: 150, height: 50)
                                    .background(
                                        Image("onboarding_btn_multi")
                                            .resizable()
                                            .scaledToFill()
                                    )
                            } else {
                                Text(state.nextText())
                                    .font(.custom("rubik-semibold", size: 20))
                                    .foregroundColor(Color.white)
                                    .frame(width: 150, height: 50)
                                    .background(
                                        ZStack {
                                            switch state {
                                            case .first, .third:
                                                Image("onboarding_btn_green")
                                                    .resizable()
                                                    .scaledToFill()
                                            case .second, .fourth:
                                                Image("onboarding_btn_purple")
                                                    .resizable()
                                                    .scaledToFill()
                                            case .fifth:
                                                Image("onboarding_btn_multi")
                                                    .resizable()
                                                    .scaledToFill()
                                            }
                                        }
                                    )
                            }
                        }
                        .animation(nil, value: UUID())
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 25)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .background(
            Image("onboarding_background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea())
        .preferredColorScheme(.dark)
    }
    
    
    struct OnboardingTitle: View {
        
        @Binding
        var state: OnboardingState
        
        var body: some View {
            HStack(spacing: 0) {
                switch state {
                case .first:
                    Image("onboarding_title_1")
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 49)
                        .transition(.backslide.combined(with: .opacity))
                case .second:
                    Image("onboarding_title_2")
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 49)
                        .transition(.backslide.combined(with: .opacity))
                case .third:
                    Image("onboarding_title_3")
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 49)
                        .transition(.backslide.combined(with: .opacity))
                case .fourth:
                    Image("onboarding_title_4")
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 49)
                        .transition(.backslide.combined(with: .opacity))
                case .fifth:
                    Image("onboarding_title_5")
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 49)
                        .transition(.backslide.combined(with: .opacity))
                }
                
                Spacer()
            }
        }
    }
    
    struct OnboardingStatePanel: View {
        
        @Binding
        var state: OnboardingState
        
        var body: some View {
            HStack(spacing: 10) {
                ForEach(1...5, id: \.self) { num in
                    if num == state.rawValue {
                        if num % 2 == 0 {
                            Image("ic_onboarding_star_second")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                        } else {
                            Image("ic_onboarding_star_first")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                        }
                    } else {
                        Image("ic_onboarding_star")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                    }
                }
                Spacer()
            }
        }
    }
    
    enum OnboardingState: Int {
        case first = 1
        case second = 2
        case third = 3
        case fourth = 4
        case fifth = 5
        
        func nextText() -> String {
            switch self {
            case .first:
                return "Hello!"
            case .second:
                 return "Wow!"
            case .third:
                return "Ok, maybe"
            case .fourth:
                return "Hmm..."
            case .fifth:
                return "GOT IT!"
            }
        }
    }
}

struct StrokeText: View {
    let text: String
    let width: CGFloat
    let color: Color

    var body: some View {
        ZStack{
            ZStack{
                Text(text)
                    .font(Font.custom("rubik-bold", fixedSize: 30))
                    .multilineTextAlignment(.center)
                    .offset(x:  width, y:  width)
                Text(text)
                    .font(Font.custom("rubik-bold", fixedSize: 30))
                    .multilineTextAlignment(.center)
                    .offset(x: -width, y: -width)
                Text(text)
                    .font(Font.custom("rubik-bold", fixedSize: 30))
                    .multilineTextAlignment(.center)
                    .offset(x: -width, y:  width)
                Text(text)
                    .font(Font.custom("rubik-bold", fixedSize: 30))
                    .multilineTextAlignment(.center)
                    .offset(x:  width, y: -width)
            }
            .foregroundColor(color)
            Text(text)
                .font(Font.custom("rubik-bold", fixedSize: 30))
                .multilineTextAlignment(.center)
                .foregroundColor(Color.black)
        }
    }
}
