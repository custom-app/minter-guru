//
//  SwipeRefresh.swift
//  CryptoInsta
//
//  Created by Lev Baklanov on 02.07.2022.
//

import SwiftUI

struct SwipeRefresh: View {
    
    @EnvironmentObject
    var globalVm: GlobalViewModel
    
    private static let minRefreshTimeInterval = TimeInterval(0.2)
    private static let triggerHeight = CGFloat(90)
    private static let indicatorHeight = CGFloat(60)
    private static let fullHeight = triggerHeight + indicatorHeight
    
    let backgroundColor: Color
    let foregroundColor: Color
    let animate: Bool
    let isEnabled: Bool
    let onRefresh: () -> Void
    
    @State private var isRefreshIndicatorVisible = false
    @State private var refreshStartTime: Date? = nil
    
    init(bg: Color = .white, fg: Color = .black, animate: Bool = true, isEnabled: Bool = true, onRefresh: @escaping () -> Void) {
        self.backgroundColor = bg
        self.foregroundColor = fg
        self.animate = animate
        self.isEnabled = isEnabled
        self.onRefresh = onRefresh
    }
    
    var body: some View {
        VStack(spacing: 0) {
            LazyVStack(spacing: 0) {
                Color.clear
                    .frame(height: Self.triggerHeight)
                    .onAppear {
                        if isEnabled {
                            withAnimation {
                                isRefreshIndicatorVisible = true
                            }
                            refreshStartTime = Date()
                        }
                        globalVm.vibrationWorker.vibrate()
                    }
                    .onDisappear {
                        if isEnabled,
                            isRefreshIndicatorVisible,
                            let diff = refreshStartTime?.distance(to: Date()),
                            diff > Self.minRefreshTimeInterval {
                            onRefresh()
                        }
                        withAnimation {
                            isRefreshIndicatorVisible = false
                        }
                        refreshStartTime = nil
                    }
            }
            .frame(height: Self.triggerHeight)
            
            Indicator(animate: animate, isRefreshIndicatorVisible: isRefreshIndicatorVisible)
//                .frame(height: Self.indicatorHeight)
        }
        .background(backgroundColor)
        .ignoresSafeArea(edges: .all)
        .frame(height: Self.fullHeight)
        .padding(.top, -Self.fullHeight)
    }
}

struct Indicator: View {
    
    var animate: Bool = true
    
    var isRefreshIndicatorVisible: Bool = false
    
    var body: some View {
        MinterProgress(animate: animate)
            .opacity(isRefreshIndicatorVisible ? 1 : 0)
        
    }
}
