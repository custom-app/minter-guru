//
//  WalletConnectWorker.swift
//  CryptoInsta
//
//  Created by Lev Baklanov on 01.06.2022.
//

import Foundation
import WalletConnectSwift
import SwiftUI

// Wallet connect logic for global viewmodel
extension GlobalViewModel {
    
    var walletAccount: String? {
        return connectedAddress ?? session?.walletInfo!.accounts[0].lowercased()
    }
    
    var walletName: String {
        if connectedAddress != nil {
            return "Address"
        } else {
            if let name = session?.walletInfo?.peerMeta.name {
                return name
            }
            return currentWallet?.name ?? ""
        }
    }
    
    var isWrongChain: Bool {
        if connectedAddress != nil {
            return false
        } else {
            if let chainId = session?.walletInfo?.chainId,
               chainId != Constants.requiredChainId {
                return true
            }
            return false
        }
    }
    
    func openWallet() {
        if let wallet = currentWallet {
            if let url = URL(string: wallet.formLinkForOpen()),
               UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                //TODO: mb show message for wallet verification only in this case?
            }
        }
    }

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
        guard let walletConnect = walletConnect else { return }
        withAnimation {
            connectingToBridge = true
        }
        let connectionUrl = walletConnect.connect()
        pendingDeepLink = wallet.formWcDeepLink(connectionUrl: connectionUrl)
        currentWallet = wallet
    }
    
    func disconnect() {
        DispatchQueue.main.async {
            if self.connectedAddress != nil {
                withAnimation {
                    self.connectedAddress = nil
                    self.isAgentAccount = false
                }
            } else {
                guard let session = self.session, let walletConnect = self.walletConnect else { return }
                try? walletConnect.client?.disconnect(from: session)
                UserDefaults.standard.removeObject(forKey: Constants.sessionKey)
            }
            withAnimation {
                self.session = nil
                self.currentWallet = nil
                self.pendingDeepLink = nil
                self.isConnecting = false
                self.isReconnecting = false
                self.connectingToBridge = false
                self.mintInProgress = false
                self.purchasingInProgress = false
                self.refreshingPublicNfts = false
                self.refreshingPrivateNfts = false
                self.rewards = nil
            }
            self.stopObservingBalance()
            self.stopObservingAllowance()
            self.stopObservingTokensCount()
            self.stopObservingPrivateCollections()
            self.stopObservingPrivateTokensCount()
            self.clearAccountInfo()
            self.objectWillChange.send()
        }
    }
    
    func triggerPendingDeepLink() {
        guard let deepLink = pendingDeepLink else { return }
        pendingDeepLink = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + deepLinkDelay) {
            withAnimation {
                self.connectingToBridge = false
            }
            if let url = URL(string: deepLink), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                //TODO: deeplink into app in store
            }
        }
        backgroundManager.createConnectBackgroundTask()
    }
    
}

extension GlobalViewModel: WalletConnectDelegate {
    func failedToConnect() {
        print("failed to connect")
        backgroundManager.finishConnectBackgroundTask()
        DispatchQueue.main.async { [unowned self] in
            withAnimation {
                connectingToBridge = false
                isConnecting = false
                isReconnecting = false
            }
            //TODO: handle error
        }
    }

    func didConnect() {
        print("did connect callback")
        backgroundManager.finishConnectBackgroundTask()
        DispatchQueue.main.async { [unowned self] in
            withAnimation {
                isConnecting = false
                isReconnecting = false
                session = walletConnect?.session
                if currentWallet == nil {
                    currentWallet = Wallets.bySession(session: session)
                }
                showConnectSheet = false
            }
            if !isWrongChain {
                loadInitialInfo()
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
                clearAccountInfo()
                loadInitialInfo()
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
