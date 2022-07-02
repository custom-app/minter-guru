//
//  SwipeRefresh.swift
//  CryptoInsta
//
//  Created by Lev Baklanov on 02.07.2022.
//

import SwiftUI

struct PullToRefreshView: View {
    private static let minRefreshTimeInterval = TimeInterval(0.2)
    private static let triggerHeight = CGFloat(90)
    private static let indicatorHeight = CGFloat(60)
    private static let fullHeight = triggerHeight + indicatorHeight
    
    let backgroundColor: Color
    let foregroundColor: Color
    let isEnabled: Bool
    let onRefresh: () -> Void
    
    @State private var isRefreshIndicatorVisible = false
    @State private var refreshStartTime: Date? = nil
    
    init(bg: Color = .white, fg: Color = .black, isEnabled: Bool = true, onRefresh: @escaping () -> Void) {
        self.backgroundColor = bg
        self.foregroundColor = fg
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
            
            indicator
//                .frame(height: Self.indicatorHeight)
        }
        .background(backgroundColor)
        .ignoresSafeArea(edges: .all)
        .frame(height: Self.fullHeight)
        .padding(.top, -Self.fullHeight)
    }
    
    private var indicator: some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: Color.black))
            .opacity(isRefreshIndicatorVisible ? 1 : 0)
            .frame(height: 50)
    }
}
