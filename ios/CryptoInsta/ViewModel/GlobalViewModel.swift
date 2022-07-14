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
import BigInt
import Combine
import web3swift

class GlobalViewModel: ObservableObject {
    
    //TODO: move to consts
    let deepLinkDelay = 0.25
    let mintLabel = "mint"
    let privateMintLabel = "private_mint"
    let purchaseCollectionLabel = "purchase_collection"
    
    @Published
    var showConnectSheet = false
    
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
    var connectingToBridge = false
    @Published
    var mintInProgress = false
    @Published
    var showMintFinishedSheet = false
    
    @Published
    var currentTab: TabItem = .wallet
    
    @Published
    var pickedImage: UIImage?
    @Published
    var mintedImage: UIImage?
    @Published
    var pictureName = ""
    @Published
    var mintedPictureName = ""
    @Published
    var pickedPrivateCollection = false
    @Published
    var pickedCollection: PrivateCollection?
    @Published
    var mintedPictureCollection = ""
    @Published
    var privateCollections: [PrivateCollection] = []
    @Published
    var privateCollectionsLoaded = false
    @Published
    var purchasingInProgress = false
    @Published
    var purchaseFinished = false
    
    @Published
    var alert: IdentifiableAlert?
    
    var backgroundManager = BackgroundTasksManager.shared
    var web3 = Web3Worker(endpoint: Config.endpoint)
    
    @Published
    var publicTokensCount = 0
    @Published
    var privateCollectionsCount = 0
    @Published
    var privateCollectionPrice: BigUInt = 0
    @Published
    var minterBalance: BigUInt = 0
    @Published
    var loadedMinterBalance = false
    
    @Published
    var nftList: [Nft] = []
    @Published
    var nftListLoaded = false
    
    private let updateInterval: Double = 1
    
    private var observingNftsCount = false
    private var nftsRequestTimer: AnyCancellable?
    private var lastNftsCount: Int?
    
    private var observingCollectionsCount = false
    private var collectionsRequestTimer: AnyCancellable?
    private var lastCollectionsCount: Int?
    
    @Published
    var refreshingNfts = false
    
    var isPassBought: Bool {
        return true
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
    
    func uploadImageToIpfs(image: UIImage,
                           name: String,
                           quality: Double = 0.85) {
        if let address = walletAccount, address.count > 2 {
            DispatchQueue.main.async {
                withAnimation {
                    self.mintInProgress = true
                }
            }
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
                        self.uploadMetaToIpfs(meta: meta,
                                              filename: "\(filename)_meta.json",
                                              filebaseImageName: "\(filename).jpg")
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                self.alert = IdentifiableAlert.build(
                    id: "wallet_not_connected",
                    title: "Wallet not connected",
                    message: "You must connect a wallet to mint the image")
            }
        }
    }
    
    func uploadMetaToIpfs(meta: NftMeta, filename: String, filebaseImageName: String) {
        print("uploading meta to ipfs")
        DispatchQueue.global(qos: .userInitiated).async { [self] in
            HttpRequester.shared.uploadMetaToFilebase(meta: meta, filename: filename) { cid, error in
                if let error = error {
                    print("Error uploading meta: \(error)")
                    return
                }
                if let cid = cid {
                    print("uploaded meta: \(cid)")
                    DispatchQueue.main.async {
                        withAnimation {
                            self.mintedImage = self.pickedImage
                            self.pickedImage = nil
                            self.mintedPictureName = self.pictureName
                            self.pictureName = ""
                            self.mintedPictureCollection = self.pickedCollection?.data.name ?? ""
                        }
                        if let collection = self.pickedCollection {
                            self.privateMint(contract: collection.address,
                                             metaUrl: "ipfs://\(cid)",
                                             nftData: NftData(name: self.mintedPictureName,
                                                       createDate: Date().timestamp(),
                                                       filebaseName: filebaseImageName))
                        } else {
                            self.publicMint(metaUrl: "ipfs://\(cid)",
                                      nftData: NftData(name: self.mintedPictureName,
                                                       createDate: Date().timestamp(),
                                                       filebaseName: filebaseImageName))
                        }
                    }
                }
            }
        }
    }
    
    func loadNftMeta(nft: Nft, loadImageAfter: Bool = false) {
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
                            if loadImageAfter {
                                self.loadImageFromIpfs(meta: meta, tokenId: nft.id)
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
    
    func loadImageFromIpfs(meta: NftMeta, tokenId: Int) {
        print("loading image from ipfs")
        DispatchQueue.global(qos: .userInitiated).async {
            if let url = URL(string: meta.httpImageLink()) {
                URLSession.shared.dataTask(with: url) { [self] data, response, error in
                    print("got image response: \(error)")
                    guard error == nil, let data = data else {
                        //TODO: handle error
                        return
                    }
                    let image = UIImage(data: data)
                    DispatchQueue.main.async {
                        print("searching index")
                        if let index = self.nftList.firstIndex(where: { $0.id == tokenId}) {
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
    
    func loadImageFromFilebase(nft: Nft) {
        print("loading image from filebase")
        DispatchQueue.global(qos: .userInitiated).async {
            if let filebaseName = nft.data.filebaseName,
                let url = URL(string: Tools.formFilebaseLink(filename: filebaseName)) {
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
    
    // Web3 calls
    
    func getPublicTokensCount() {
        print("requesting tokens count")
        if let address = walletAccount {
            web3.getPublicTokensCount(address: address) { [weak self] count, error in
                if let error = error {
                    print("get public tokens count error: \(error)")
                    //TODO: handle error?
                } else {
                    print("got public tokens count: \(count)")
                    if let observing = self?.observingNftsCount, let lastCount = self?.lastNftsCount, observing {
                        if count > lastCount {
                            self?.nftsRequestTimer?.cancel()
                            self?.getPublicTokens(page: 0)
                        }
                    } else {
                        withAnimation {
                            self?.publicTokensCount = Int(count)
                            if count == 0 {
                                self?.nftListLoaded = true
                            }
                            self?.getPublicTokens(page: 0)
                        }
                    }
                }
            }
        }
    }
    
    func getPublicTokens(page: Int, size: Int = 1000) {
        if let address = walletAccount {
            web3.getPublicTokens(page: page, size: size, address: address) { [weak self] tokens, error in
                if let error = error {
                    print("get public tokens error: \(error)")
                    //TODO: handle error?
                } else {
                    print("got public tokens: \(tokens)")
                    DispatchQueue.main.async {
                        withAnimation {
                            self?.nftList = tokens
                            self?.nftListLoaded = true
                            self?.refreshingNfts = false
                        }
                        if let observing = self?.observingNftsCount,
                            let lastCount = self?.lastNftsCount,
                           observing && tokens.count > lastCount {
                            self?.stopObservingTokensCount()
                            self?.showMintFinishedSheet = true
                            self?.mintInProgress = false
                        }
                    }
                }
            }
        }
    }
    
    func publicMint(metaUrl: String, nftData: NftData) {
        do {
            let data = try JSONEncoder().encode(nftData)
            guard let data = web3.mintWithoutIdData(version: BigUInt(Constants.currentVersion),
                                                    metaUrl: metaUrl,
                                                    data: data) else {
                //TODO: handle error
                return
            }
            prepareAndSendTx(to: Constants.routerAddress, data: data, label: mintLabel)
        } catch {
            print("Error encoding NftData: \(error)")
            //TODO: handle error
        }
    }
    
    func privateMint(contract: String, metaUrl: String, nftData: NftData) {
        print("minting to private collection")
        if let address = walletAccount, let mintTo = EthereumAddress(address) {
            do {
                let data = try JSONEncoder().encode(nftData)
                guard let data = web3.privateMintData(to: mintTo,
                                                      metaUrl: metaUrl,
                                                      data: data) else {
                    print("error getting data")
                    //TODO: handle error
                    return
                }
                prepareAndSendTx(to: contract, data: data, label: privateMintLabel)
            } catch {
                print("Error encoding NftData: \(error)")
                //TODO: handle error
            }
        } else {
            print("Invalid address for private mint")
            //TODO: handle error
        }
    }
    
    func purchaseCollection(collectionData: PrivateCollectionData) {
        if let address = walletAccount {
            do {
                let data = try JSONEncoder().encode(collectionData)
                let salt = Tools.sha256(data: (address + "\(Date())").data(using: .utf8)!)
                guard let data = web3.purchasePrivateCollectionData(salt: salt,
                                                                    name: collectionData.name,
                                                                    symbol: "",
                                                                    data: data) else {
                    //TODO: handle error
                    return
                }
                withAnimation {
                    self.purchasingInProgress = true
                }
                prepareAndSendTx(to: Constants.accessTokenAddress, data: data, label: purchaseCollectionLabel)
            } catch {
                print("Error encoding PrivatecollectionData: \(error)")
                //TODO: handle error
            }
        }
    }
    
    func getPrivateCollectionPrice() {
        print("requesting private collection price")
        web3.getPrivateCollectionPrice() { [weak self] price, error in
            if let error = error {
                print("get private collection price error: \(error)")
                //TODO: handle error?
            } else {
                print("got private collection price: \(price)")
                withAnimation {
                    self?.privateCollectionPrice = price
                }
            }
        }
    }
    
    func getMinterBalance() {
        if let address = walletAccount {
            print("requesting minter balance")
            web3.getMinterBalance(address: address) { [weak self] balance, error in
                if let error = error {
                    print("get minter balance error: \(error)")
                    //TODO: handle error?
                } else {
                    print("got minter balance: \(balance)")
                    withAnimation {
                        self?.minterBalance = balance
                        self?.loadedMinterBalance = true
                    }
                }
            }
        }
    }
    
    func getPrivateCollectionsCount() {
        if let address = walletAccount {
            web3.getPrivateCollectionsCount(address: address) { [weak self] count, error in
                if let error = error {
                    print("get private collections count error: \(error)")
                    //TODO: handle error?
                } else {
                    print("get private collections count: \(count)")
                    if let observing = self?.observingCollectionsCount, let lastCount = self?.lastCollectionsCount, observing {
                        if count > lastCount {
                            self?.collectionsRequestTimer?.cancel()
                            self?.getPrivateCollections()
                        }
                    } else {
                        withAnimation {
                            self?.privateCollectionsCount = Int(count)
                            if count == 0 {
                                self?.privateCollectionsLoaded = true
                            } else {
                                self?.getPrivateCollections()
                            }
                        }
                    }
                }
            }
        }
    }
    
    func getPrivateCollections(page: Int = 0, size: Int = 1000) {
        if let address = walletAccount {
            web3.getPrivateCollections(page: page, size: size, address: address) { [weak self] collections, error in
                if let error = error {
                    print("get private collections error: \(error)")
                    //TODO: handle error?
                } else {
                    print("get private collections: \(collections)")
                    DispatchQueue.main.async {
                        withAnimation {
                            self?.privateCollections = collections
                            self?.privateCollectionsLoaded = true
                        }
                        if let observing = self?.observingCollectionsCount,
                            let lastCount = self?.lastCollectionsCount,
                           observing && collections.count > lastCount {
                            print("stopping observing")
                            self?.stopObservingPrivateCollections()
                            self?.purchaseFinished = true
                            self?.purchasingInProgress = false
                            self?.getMinterBalance()
                        }
                    }
                }
            }
        }
    }
    
    func prepareAndSendTx(to: String, data: String = "", label: String) {
        guard let session = session,
              let client = walletConnect?.client,
              let from = walletAccount else {
            //TODO: handle error
            return
        }
        let tx = TxWorker.construct(from: from, to: to, data: data)
        do {
            try client.eth_sendTransaction(url: session.url,
                                           transaction: tx) { [weak self] response in
                DispatchQueue.main.async {
                    self?.backgroundManager.finishSendTxBackgroundTask()
                    //TODO: handle response
                }
                if let error = response.error {
                    print("Got error response for \(label) tx: \(error)")
                } else {
                    do {
                        let result = try response.result(as: String.self)
                        print("Got response for \(label) tx: \(result)")
                    } catch {
                        print("Unexpected response type error: \(error)")
                    }
                    switch label {
                    case self?.mintLabel:
                        self?.startObservingTokensCount()
                    case self?.purchaseCollectionLabel:
                        self?.startObservingPrivateCollections()
                    default:
                        print("unknown tx label: \(label)")
                    }
                }
            }
            print("sending tx: \(label)")
            DispatchQueue.main.async {
                self.backgroundManager.createSendTxBackgroundTask()
                self.openWallet()
            }
        } catch {
            print("error sending tx: \(error)")
            //TODO: handle error
        }
    }
    
    func startObservingTokensCount() {
        nftsRequestTimer?.cancel()
        observingNftsCount = true
        lastNftsCount = nftList.count
        nftsRequestTimer = Timer.publish(every: updateInterval,
                              tolerance: updateInterval/2,
                              on: .main,
                              in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.getPublicTokensCount()
        }
    }
    
    func stopObservingTokensCount() {
        observingNftsCount = false
        nftsRequestTimer?.cancel()
    }
    
    func startObservingPrivateCollections() {
        collectionsRequestTimer?.cancel()
        observingCollectionsCount = true
        lastCollectionsCount = privateCollections.count
        collectionsRequestTimer = Timer.publish(every: updateInterval,
                              tolerance: updateInterval/2,
                              on: .main,
                              in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.getPrivateCollectionsCount()
        }
    }
    
    func stopObservingPrivateCollections() {
        observingCollectionsCount = false
        collectionsRequestTimer?.cancel()
    }
    
    func refreshNfts() {
        DispatchQueue.main.async {
            withAnimation {
                self.refreshingNfts = true
            }
        }
        getPublicTokens(page: 0)
    }
}