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
    
    let deepLinkDelay = 0.5
    
    //Wallet connect block
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
    @Published
    var connectingWalletName = ""
    
    @Published
    var currentTab: TabItem = .wallet
    
    @Published
    var pickedImage: UIImage?
    
    @Published
    var alert: IdentifiableAlert?
    
    var backgroundManager = BackgroundTasksManager.shared
    
    var web3 = Web3Worker(endpoint: Config.TESTING ?
                          Config.PolygonEndpoints.Testnet : Config.PolygonEndpoints.Mainnet)
    
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
    
    func uploadImageToIpfs(image: UIImage,
                           quality: Double = 0.85,
                           onSuccess: @escaping (String) -> ()) {
        if let address = walletAccount, address.count > 2 {
        print("uploading image to ipfs")
            DispatchQueue.global(qos: .userInitiated).async { [self] in
                guard let data = image.jpegData(compressionQuality: quality) else {
                    print("error getting jpeg data for photo")
                    return
                }
                let filename = Tools.generatePictureName(address: address)
                HttpRequester.shared.uploadPictureToFilebase(data: data, filename: filename) { cid, error in
                    if let error = error {
                        print("Error uploading photo: \(error)")
                        return
                    }
                    if let cid = cid {
                        print("uploaded photo: \(cid)")
                    }
                }
            }
        } else {
            //TODO: show alert that user should connect wallet to upload photo
        }
    }
}
