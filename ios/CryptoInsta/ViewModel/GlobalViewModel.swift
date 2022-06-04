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
    
    @Published
    var nftList: [NftObject] = []
    @Published
    var nftListLoaded = false
    
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
                           name: String,
                           quality: Double = 0.85) {
        if let address = walletAccount, address.count > 2 {
        print("uploading image to ipfs")
            DispatchQueue.global(qos: .userInitiated).async { [self] in
                guard let data = image.jpegData(compressionQuality: quality) else {
                    print("error getting jpeg data for photo")
                    return
                }
                let filename = (Tools.generatePictureName(address: address))
                HttpRequester.shared.uploadPictureToFilebase(data: data, filename: "\(filename).jpg") { cid, error in
                    if let error = error {
                        print("Error uploading photo: \(error)")
                        return
                    }
                    if let cid = cid {
                        print("uploaded photo: \(cid)")
                        let meta = NftMeta(name: name,
                                           description: "",
                                           image: "ipfs://\(cid)",
                                           properties: MetaProperties(
                                            id: "1",
                                            imageName: filename))
                        self.uploadMetaToIpfs(meta: meta, filename: "\(filename)_meta.json")
                    }
                }
            }
        } else {
            //TODO: show alert that user should connect wallet to upload photo
        }
    }
    
    func uploadMetaToIpfs(meta: NftMeta, filename: String) {
        print("uploading meta to ipfs")
        DispatchQueue.global(qos: .userInitiated).async { [self] in
            HttpRequester.shared.uploadMetaToFilebase(meta: meta, filename: filename) { cid, error in
                if let error = error {
                    print("Error uploading meta: \(error)")
                    return
                }
                if let cid = cid {
                    print("uploaded meta: \(cid)")
                }
            }
        }
    }
    
    func loadNftList() {
        print("loading list")
        //TODO: unmock
        DispatchQueue.global(qos: .userInitiated).async {
            let nft1 = NftObject(metaUrl: "ipfs://QmXFn9DnZQGxEjHbwbc4kyZUWX5GQepov1is8bVCnGm573")
            let nft2 = NftObject(metaUrl: "ipfs://QmfDjV1hnYThocfbgsXZPdJbnHWdWVckZufmtQ87Sgncv1")
            let nft3 = NftObject(metaUrl: "ipfs://QmYrtUVi4DUM8KSCz3m8YH5mfGXaivd2hXhL7ZUMcaQ3r4")
            let nft4 = NftObject(metaUrl: "ipfs://QmUu1yosmZk3c3sR9XCPMzFj455eoJdJcKKh2Stp5xH5iM")
            DispatchQueue.main.async { [self] in
                withAnimation {
                    self.nftList = [nft1, nft2, nft3, nft4]
                }
                DispatchQueue.global(qos: .userInitiated).async {
                    self.loadNftMeta()
                }
            }
        }
    }
    
    func loadNftMeta() {
        for nft in nftList {
            if let url = URL(string: Tools.ipfsLinkToHttp(ipfsLink: nft.metaUrl)) {
                HttpRequester.shared.loadMeta(url: url) { [self] meta, error in
                    if error != nil {
                        //TODO: handle error
                        print("error getting meta: \(error)")
                    } else if let meta = meta {
                        DispatchQueue.main.async {
                            if let index = self.nftList.firstIndex(where: { $0.metaUrl == nft.metaUrl}) {
                                withAnimation {
                                    self.nftList[index].meta = meta
                                }
                            }
                        }
                    } else {
                        //should never happen
                        print("got nil meta w/o error")
                    }
                }
            }
        }
    }
    
    func loadImage(nft: NftObject) {
        DispatchQueue.global(qos: .userInitiated).async {
            if let meta = nft.meta, let url = URL(string: Tools.formFilebaseLink(filename: "\(meta.properties.imageName).jpg")) {
                URLSession.shared.dataTask(with: url) { [self] data, response, error in
                    print("got image response: \(error)")
                    guard error == nil, let data = data else {
                        //TODO: handle error
                        return
                    }
                    let image = UIImage(data: data)
                    DispatchQueue.main.async {
                        print("searching index")
                        if let index = self.nftList.firstIndex(where: { $0.metaUrl == nft.metaUrl}) {
                            print("index found")
                            withAnimation {
                                self.nftList[index].image = image
                            }
                        }
                    }
                }
                .resume()
            } else {
                //TODO: handle error
            }
        }
    }
}
