//
//  WalletConnectWorker.swift
//  CryptoInsta
//
//  Created by Lev Baklanov on 01.06.2022.
//

import Foundation
import WalletConnectSwift
import SwiftUI

class WalletConnectWorker: ObservableObject {
    
    private let deepLinkDelay = 0.5
    
    @Published
    var session: Session?
    @Published
    var currentWallet: Wallet?
    @Published
    var isConnecting: Bool = false
    @Published
    var isReconnecting: Bool = false
    @Published
    var walletConnect: WalletConnect?
    
    var pendingDeepLink: String?
    
    var backgroundManager = BackgroundTasksManager.shared
    
    
    func initWalletConnect() {
        print("init wallet connect: \(walletConnect == nil)")
        if walletConnect == nil {
            walletConnect = WalletConnect(delegate: self)
            if walletConnect!.haveOldSession() {
                withAnimation {
                    isConnecting = true
                }
                walletConnect!.reconnectIfNeeded()
            }
        }
    }
    
    func connect(wallet: Wallet) {
        guard let walletConnect = walletConnect else { return  }
        let connectionUrl = walletConnect.connect()
        pendingDeepLink = wallet.formWcDeepLink(connectionUrl: connectionUrl)
        currentWallet = wallet
    }
    
    func disconnect() {
        guard let session = session, let walletConnect = walletConnect else { return }
        try? walletConnect.client?.disconnect(from: session)
        withAnimation {
            self.session = nil
        }
        UserDefaults.standard.removeObject(forKey: Constants.sessionKey)
    }
    
    func triggerPendingDeepLink() {
        guard let deepLink = pendingDeepLink else { return }
        pendingDeepLink = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + deepLinkDelay) {
            if let url = URL(string: deepLink), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                //TODO: deeplink into app in store
            }
        }
        backgroundManager.createConnectBackgroundTask()
    }
    
}

extension WalletConnectWorker: WalletConnectDelegate {
    func failedToConnect() {
        print("failed to connect")
        backgroundManager.finishConnectBackgroundTask()
        DispatchQueue.main.async { [unowned self] in
            withAnimation {
                isConnecting = false
                isReconnecting = false
            }
            //TODO: handle error
        }
    }

    func didConnect() {
        print("did connect")
        backgroundManager.finishConnectBackgroundTask()
        DispatchQueue.main.async { [unowned self] in
            withAnimation {
                isConnecting = false
                isReconnecting = false
                session = walletConnect?.session
                if currentWallet == nil {
                    currentWallet = Wallets.bySession(session: session)
                }
                //TODO: load initial info here
            }
        }
    }
    
    func didSubscribe(url: WCURL) {
        triggerPendingDeepLink()
    }
    
    func didUpdate(session: Session) {
        var accountChanged = false
        if let curSession = self.session,
           let curInfo = curSession.walletInfo,
           let info = session.walletInfo,
           let curAddress = curInfo.accounts.first,
           let address = info.accounts.first,
           curAddress != address || curInfo.chainId != info.chainId {
            accountChanged = true
            do {
                let sessionData = try JSONEncoder().encode(session)
                UserDefaults.standard.set(sessionData, forKey: Constants.sessionKey)
            } catch {
                print("Error saving session in update: \(error)")
            }
        }
        DispatchQueue.main.async { [unowned self] in
            withAnimation {
                self.session = session
            }
            if accountChanged {
                //TODO: load new data
            }
        }
    }

    func didDisconnect(isReconnecting: Bool) {
        print("did disconnect, is reconnecting: \(isReconnecting)")
        if !isReconnecting {
            backgroundManager.finishConnectBackgroundTask()
            DispatchQueue.main.async { [unowned self] in
                withAnimation {
                    isConnecting = false
                    session = nil
                }
            }
        }
        DispatchQueue.main.async { [unowned self] in
            withAnimation {
                self.isReconnecting = isReconnecting
            }
        }
    }
}
