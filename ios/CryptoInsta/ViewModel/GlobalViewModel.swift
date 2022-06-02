//
//  GlobalViewModel.swift
//  CryptoInsta
//
//  Created by Lev Baklanov on 01.06.2022.
//

import Foundation
import SwiftUI
import PhotosUI
import WalletConnectSwift

class GlobalViewModel: ObservableObject {
    
    @Published
    var currentTab: TabItem = .wallet
    
    @Published
    var pickedImage: UIImage?
    
    @Published
    var alert: IdentifiableAlert?
    
    @Published
    var wcWorker = WalletConnectWorker()
    
    private var backgroundManager = BackgroundTasksManager.shared
    
    var walletAccount: String? {
        return wcWorker.session?.walletInfo!.accounts[0].lowercased()
    }
    
    var walletName: String {
        if let name = wcWorker.session?.walletInfo?.peerMeta.name {
            return name
        }
        return wcWorker.currentWallet?.name ?? ""
    }
    
    var isWrongChain: Bool {
        let requiredChainId = Config.TESTING ? Constants.ChainId.PolygonTestnet : Constants.ChainId.Polygon
        if let session = wcWorker.session,
           let chainId = session.walletInfo?.chainId,
           chainId != requiredChainId {
            return true
        }
        return false
    }
    
    func initWalletConnect() {
        wcWorker.initWc()
    }
    
    func connect(wallet: Wallet) {
        wcWorker.connect(wallet: wallet)
    }
    
    func disconnect() {
        wcWorker.disconnect()
    }
    
    func openWallet() {
        if let wallet = wcWorker.currentWallet {
            if let url = URL(string: wallet.formLinkForOpen()),
               UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                //TODO: mb show message for wallet verification only in this case?
            }
        }
    }
    
    func checkGalleryAuth(onSuccess: @escaping () -> ()) {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized, .limited:
            onSuccess()
        case .denied, .restricted:
            alert = IdentifiableAlert.build(
                id: "photo library access",
                title: "Access denied",
                message: "You need to give permission for photos in settings"
            )
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { newStatus in
                if newStatus == .authorized {
                    onSuccess()
                }
            }
        @unknown default:
            print("Unknown photo library authorization status")
        }
    }
    
    func handleImagePicked(photo: UIImage) {
        DispatchQueue.global(qos: .userInitiated).async { [self] in
            let compressed = ImageWorker.compressImage(image: photo)
            DispatchQueue.main.async {
                withAnimation {
                    self.pickedImage = compressed
                }
            }
        }
    }
}
