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
import CoreHaptics

class GlobalViewModel: ObservableObject {
    
    //TODO: move to consts
    let deepLinkDelay = 0.25
    let imageSidesMaxRatio = 2.5
    let requestsInterval: Double = 1
    let mintLabel = "mint"
    let privateMintLabel = "private_mint"
    let approveTokensLabel = "approve_tokens"
    let purchaseCollectionLabel = "purchase_collection"
    
    var vibrationWorker = VibrationWorker()
    
    @Published
    var showingOnboarding: Bool
    
    @Published
    var showConnectSheet = false
    
    //Wallet connect block
    @Published
    var session: Session?
    @Published
    var connectedAddress: String? // not nil if authorized throught address
    @Published
    var isAgentAccount = false
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
    var pickedImage: UIImageWithFormat?
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
    var web3 = Web3Worker(endpoint: Config.polygonEndpoint)
    
    @Published
    var polygonBalance = 0.0
    @Published
    var polygonBalanceLoaded = false
    @Published
    var faucetUsed = false
    @Published
    var publicTokensCount = 0
    @Published
    var privateCollectionsCount = 0
    @Published
    var privateCollectionPrice: BigUInt = 0
    @Published
    var privateCollectionPriceLoaded = false
    @Published
    var minterBalance: BigUInt = 0
    @Published
    var loadedMinterBalance = false
    @Published
    var allowance: BigUInt = 0
    @Published
    var allowanceLoaded = false
    
    @Published
    var publicNfts: [Nft] = []
    @Published
    var publicNftsLoaded = false
    
    @Published
    var privateNfts: [Nft] = []
    @Published
    var privateNftsLoaded = false
    
    @Published
    var refreshingPublicNfts = false
    @Published
    var refreshingPrivateNfts = false
    
    //Gallery state
    @Published
    var privateCollectionsInGallery = false
    @Published
    var chosenCollectionInGallery: PrivateCollection?
    @Published
    var nftSearch = ""
    
    @Published
    var twitterInfo: TwitterInfo?
    @Published
    var faucetInfo: FaucetInfo?
    @Published
    var twitterFollowInfo: TwitterFollowInfo?
    @Published
    var rewards: [RewardInfo]?
    @Published
    var faucetProcessing = false
    @Published
    var faucetFinished = false
    @Published
    var twitterFollowRewardReceived = false
    
    
    private var observingNftsCount = false
    private var nftsRequestTimer: AnyCancellable?
    private var lastNftsCount: Int?
    
    private var observingPrivateNftsCount = false
    private var privateNftsRequestTimer: AnyCancellable?
    
    private var observingCollectionsCount = false
    private var collectionsRequestTimer: AnyCancellable?
    private var lastCollectionsCount: Int?
    
    private var observingBalance = false
    private var balanceRequestTimer: AnyCancellable?
    
    private var observingAllowance = false
    private var allowanceRequestTimer: AnyCancellable?
    
    var isPassBought: Bool {
        return true
    }
    
    init() {
        if let shown = UserDefaultsWorker.shared.isOnboardingShown() {
            showingOnboarding = !shown
        } else {
            showingOnboarding = true
        }
        if let used = UserDefaultsWorker.shared.isFaucetUsed() {
            faucetUsed = used
        }
        loadGeneralInfo()
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
    
    func handleImagePicked(photo: UIImageWithFormat) {
        let sidesRatio = photo.image.size.height / photo.image.size.width
        if sidesRatio > imageSidesMaxRatio || sidesRatio < (1.0 / imageSidesMaxRatio) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.alert = IdentifiableAlert.build(
                    id: "unacceptable image sides ratio",
                    title: "Image too elongated",
                    message: "Max image sides ratio is 1:\(self.imageSidesMaxRatio)"
                )
            }
            return
        }
        DispatchQueue.global(qos: .userInitiated).async { [self] in
            let compressed = ImageWorker.compressImage(image: photo.image)
            DispatchQueue.main.async {
                withAnimation {
                    self.pickedImage = UIImageWithFormat(image: compressed, format: photo.format)
                }
            }
        }
    }
    
    func authByAddress(_ address: String) {
        connectedAddress = address
        if address == Config.agentAddress {
            isAgentAccount = true
        }
        loadInitialInfo()
        withAnimation {
            isConnecting = false
            isReconnecting = false
        }
    }
    
    func loadInitialInfo(loadNfts: Bool = true) {
        getPolygonBalance()
        getMinterBalance()
        if !faucetUsed {
            checkFaucetUsage()
        }
        checkTwitterFollow()
        getRepostRewards()
        getAllowance()
        
        if !publicNftsLoaded || publicNfts.isEmpty || loadNfts {
            getPublicTokensCount()
        }
        if !privateNftsLoaded || privateNfts.isEmpty || loadNfts {
            getPrivateCollectionsCount()
        }
    }
    
    func isAllPersonalInfoLoaded() -> Bool {
        return publicNftsLoaded && privateCollectionsLoaded &&
        allowanceLoaded && rewards != nil &&
        loadedMinterBalance && polygonBalanceLoaded
    }
    
    func loadGeneralInfo() {
        getPrivateCollectionPrice()
        getFaucetInfo()
        getTwitterInfo()
        getTwitterFollowInfo()
        getContractsConfig()
    }
    
    func clearAccountInfo() {
        polygonBalance = 0.0
        polygonBalanceLoaded = false
        publicTokensCount = 0
        minterBalance = 0
        loadedMinterBalance = false
        publicNfts = []
        publicNftsLoaded = false
        privateNfts = []
        privateNftsLoaded = false
        pickedPrivateCollection = false
        pickedCollection = nil
        chosenCollectionInGallery = nil
        privateCollections = []
    }
    
    func isRepostRewarded() -> Bool {
        if let rewards = rewards, let info = twitterInfo {
            let todayRewards = Tools.calcTodayRewards(rewards: rewards)
            return todayRewards < info.personalLimit && rewards.count < info.personalTotalLimit && info.open && info.spent < info.limit
        } else {
            return true
        }
    }
    
    func showSearch() -> Bool {
        if privateCollectionsInGallery {
            let nfts = chosenCollectionInGallery == nil ? privateNfts :
                       privateNfts.filter({ $0.contractAddress == chosenCollectionInGallery?.address })
            return !nfts.isEmpty
        } else {
            return !publicNfts.isEmpty
        }
    }
    
    func getContractsConfig() {
        DispatchQueue.global(qos: .userInitiated).async {
            HttpRequester.shared.getContractsConfig { result, error in
                if let error = error {
                    print("got contracts config error: \(error)")
                    //TODO: handle error
                } else if let result = result {
                    print("got contracts config: \(result)")
                    Constants.contractsConfig = result
                }
            }
        }
    }
    
    func callFaucet() {
        DispatchQueue.main.async {
            withAnimation {
                self.faucetProcessing = true
            }
        }
        if let address = walletAccount {
            DispatchQueue.global(qos: .userInitiated).async {
                HttpRequester.shared.callFaucet(address: address) { result, error in
                    if let error = error {
                        print("got faucet call error: \(error)")
                        //TODO: handle error
                    } else if let result = result {
                        print("faucet sucessfuly used, txid: \(result.id)")
                        self.startObservingBalance()
                    }
                }
            }
        }
    }
    
    func checkFaucetUsage() {
        if let address = walletAccount {
            DispatchQueue.global(qos: .userInitiated).async {
                HttpRequester.shared.checkFaucet(address: address) { result, error in
                    if let error = error {
                        print("got faucet check error: \(error)")
                        //TODO: handle error
                    } else if let result = result {
                        print("check faucet response, is available: \(!result.has)")
                        if result.has {
                            self.faucetUsed = true
                        }
                    }
                }
            }
        }
    }
    
    func getFaucetInfo() {
        DispatchQueue.global(qos: .userInitiated).async {
            HttpRequester.shared.getFaucetInfo { result, error in
                if let error = error {
                    print("got faucet info error: \(error)")
                    //TODO: handle error
                } else if let result = result {
                    print("got faucet info: \(result)")
                    withAnimation {
                        self.faucetInfo = result
                    }
                }
            }
        }
    }
    
    func getTwitterInfo() {
        DispatchQueue.global(qos: .userInitiated).async {
            HttpRequester.shared.getTwitterInfo { result, error in
                if let error = error {
                    print("got twitter info error: \(error)")
                    //TODO: handle error
                } else if let result = result {
                    print("got twitter info: \(result)")
                    withAnimation {
                        self.twitterInfo = result
                    }
                }
            }
        }
    }
    
    func applyForRepostReward() {
        let twitter = UserDefaultsWorker().getTwitterLogin()
        if let address = walletAccount, !twitter.isEmpty {
            DispatchQueue.global(qos: .userInitiated).async {
                HttpRequester.shared.applyForRepostReward(address: address,
                                                          twitter: "@\(twitter)") { result, error in
                    if let error = error {
                        print("apply for reward error: \(error)")
                        //TODO: handle error
                    } else if let result = result {
                        print("reward successfully requested: \(result)")
                        self.rewards?.insert(result, at: 0)
                    }
                }
            }
        }
    }
    
    func getRepostRewards() {
        print("called repost rewards")
        if let address = walletAccount {
            DispatchQueue.global(qos: .userInitiated).async {
                HttpRequester.shared.getRewards(address: address) { result, error in
                    if let error = error {
                        print("get rewards error: \(error)")
                        //TODO: handle error
                    } else if let result = result {
                        print("got rewards list: \(result)")
                        self.rewards = result
                        if self.isAllPersonalInfoLoaded() {
                            self.backgroundManager.finishConnectBackgroundTask()
                        }
                    }
                }
            }
        }
    }
    
    func getTwitterFollowInfo() {
        DispatchQueue.global(qos: .userInitiated).async {
            HttpRequester.shared.getTwitterFollowInfo { result, error in
                if let error = error {
                    print("got twitter follow info error: \(error)")
                    //TODO: handle error
                } else if let result = result {
                    print("got twitter follow info: \(result)")
                    withAnimation {
                        self.twitterFollowInfo = result
                    }
                }
            }
        }
    }
    
    func checkTwitterFollow() {
        if let address = walletAccount {
            DispatchQueue.global(qos: .userInitiated).async {
                HttpRequester.shared.checkTwitterFollow(address: address) { result, error in
                    if let error = error {
                        print("got check follow error: \(error)")
                        //TODO: handle error
                    } else if let result = result {
                        print("twitter follow result: \(result)")
                        withAnimation {
                            self.twitterFollowRewardReceived = true
                        }
                    } else {
                        print("twitter follow response is null -> not received")
                        withAnimation {
                            self.twitterFollowRewardReceived = false
                        }
                    }
                }
            }
        }
    }
    
    func applyForFollowReward() {
        let twitter = UserDefaultsWorker().getTwitterLogin()
        if let address = walletAccount, !twitter.isEmpty {
            DispatchQueue.global(qos: .userInitiated).async {
                HttpRequester.shared.applyForTwitterFollow(address: address, twitter: "@\(twitter)") { result, error in
                    if let error = error {
                        print("apply for follow reward error: \(error)")
                        //TODO: handle error
                    } else if let result = result {
                        print("follow reward successfully requested: \(result)")
                        withAnimation {
                            self.twitterFollowRewardReceived = true
                        }
                    }
                }
            }
        }
    }
    
    func uploadImageToIpfs(image: UIImageWithFormat,
                           name: String,
                           quality: Double = 1.0) {
        if let address = walletAccount, address.count > 2 {
            print("uploading image to ipfs")
            DispatchQueue.global(qos: .userInitiated).async { [self] in
                var data: Data? = nil
                if image.format == .png {
                    data = image.image.pngData()
                } else {
                    data = image.image.jpegData(compressionQuality: quality)
                }
                guard let data = data else {
                    print("error getting \(image.format) data for photo")
                    return
                }
                print("\(image.format)")
                let filename = Tools.generatePictureName(address: address)
                HttpRequester.shared.uploadPictureToFilebase(data: data, filename: "\(filename).\(image.format)") { cid, error in
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
                                            id: nil,
                                            imageName: filename))
                        self.uploadMetaToIpfs(meta: meta,
                                              filename: "\(filename)_meta.json",
                                              filebaseImageName: "\(filename).\(image.format)")
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
                            self.mintedImage = self.pickedImage?.image
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
                        if let index = self.publicNfts.firstIndex(where: { $0.metaUrl == nft.metaUrl}) {
                            withAnimation {
                                self.publicNfts[index].meta = meta
                            }
                            if loadImageAfter {
                                self.loadImageFromIpfs(meta: meta, tokenId: nft.tokenId)
                            }
                        }
                        if let index = self.privateNfts.firstIndex(where: { $0.metaUrl == nft.metaUrl}) {
                            withAnimation {
                                self.privateNfts[index].meta = meta
                            }
                            if loadImageAfter {
                                self.loadImageFromIpfs(meta: meta, tokenId: nft.tokenId)
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
                        if let index = self.publicNfts.firstIndex(where: { $0.tokenId == tokenId}) {
                            print("index found")
                            withAnimation {
                                self.publicNfts[index].image = image
                            }
                        }
                        if let index = self.privateNfts.firstIndex(where: { $0.tokenId == tokenId}) {
                            print("index found")
                            withAnimation {
                                self.privateNfts[index].image = image
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
    
    func tryToGetImageFromCache(nft: Nft, ifNotExist: @escaping (Nft) -> ()) {
        DispatchQueue.global(qos: .userInitiated).async {
            if let key = nft.data.filebaseName {
                ImageCache.shared.get(key: key) { image in
                    if let image = image {
                        DispatchQueue.main.async {
                            self.setNftPicture(image: image, nft: nft)
                        }
                    } else {
                        ifNotExist(nft)
                    }
                }
            } else {
                ifNotExist(nft)
            }
        }
    }
    
    func loadImageFromFilebase(nft: Nft) {
        DispatchQueue.global(qos: .userInitiated).async {
            if let filebaseName = nft.data.filebaseName,
                let url = URL(string: Tools.formFilebaseLink(filename: filebaseName)) {
                print("loading image from filebase: \(url.absoluteString)")
                if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.setNftPicture(image: image, nft: nft)
                    }
                    ImageCache.shared.save(image, key: filebaseName)
                } else {
                    URLSession.shared.dataTask(with: url) { [self] data, response, error in
                        print("got image response, error: \(error)")
                        guard error == nil, let data = data else {
                            //TODO: handle error
                            return
                        }
                        let image = UIImage(data: data)
                        print("is image nil: \(image == nil)")
                        DispatchQueue.main.async {
                            self.setNftPicture(image: image, nft: nft)
                        }
                        if let image = image {
                            ImageCache.shared.save(image, key: filebaseName)
                        }
                    }
                    .resume()
                }
            } else {
                //TODO: handle error
            }
        }
    }
    
    func setNftPicture(image: UIImage?, nft: Nft) {
        if let index = self.publicNfts.firstIndex(where: { $0.metaUrl == nft.metaUrl}) {
            print("index found, image: \(self.publicNfts[index].data.name)")
            withAnimation {
                self.publicNfts[index].image = image
            }
            return
        }
        if let index = self.privateNfts.firstIndex(where: { $0.metaUrl == nft.metaUrl}) {
            print("index found, image: \(self.privateNfts[index].data.name)")
            withAnimation {
                self.privateNfts[index].image = image
            }
            return
        }
    }
    
    func getMintedNft() -> Nft? {
        guard !mintedPictureName.isEmpty else { return nil }
        if mintedPictureCollection.isEmpty {
            return publicNfts.first { $0.data.name == mintedPictureName }
        } else {
            return privateNfts.first { $0.data.name == mintedPictureName }
        }
    }
    
    // Web3 calls
    
    func getPolygonBalance() {
        if let address = walletAccount {
            web3.getBalance(address: address) { [weak self] balance, error in
                if error == nil {
                    withAnimation {
                        self?.polygonBalance = balance
                        self?.polygonBalanceLoaded = true
                    }
                    if let loaded = self?.isAllPersonalInfoLoaded(), loaded {
                        self?.backgroundManager.finishConnectBackgroundTask()
                    }
                    if let observing = self?.observingBalance, observing, balance > 0 {
                        self?.stopObservingBalance()
                        withAnimation {
                            self?.faucetUsed = true
                            self?.faucetFinished = true
                            self?.faucetProcessing = false
                        }
                        self?.vibrationWorker.vibrate()
                    }
                }
            }
        }
    }
    
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
                                self?.publicNftsLoaded = true
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
                            self?.publicNfts = tokens
                            self?.publicNftsLoaded = true
                            self?.refreshingPublicNfts = false
                            if let loaded = self?.isAllPersonalInfoLoaded(), loaded {
                                self?.backgroundManager.finishConnectBackgroundTask()
                            }
                        }
                        if let observing = self?.observingNftsCount,
                            let lastCount = self?.lastNftsCount,
                           observing && tokens.count > lastCount {
                            self?.stopObservingTokensCount()
                            self?.showMintFinishedSheet = true
                            self?.mintInProgress = false
                            self?.vibrationWorker.vibrate()
                        }
                    }
                }
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
                    self?.privateCollectionPriceLoaded = true
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
                        if let loaded = self?.isAllPersonalInfoLoaded(), loaded {
                            self?.backgroundManager.finishConnectBackgroundTask()
                        }
                    }
                }
            }
        }
    }
    
    func getPrivateCollections(page: Int = 0, size: Int = 1000) {
        if let address = walletAccount {
            web3.getPrivateCollections(page: page, size: size, address: address) { [self] collections, error in
                if let error = error {
                    print("get private collections error: \(error)")
                    //TODO: handle error?
                } else {
                    print("get private collections: \(collections)")
                    DispatchQueue.main.async {
                        let oldTokensCount = self.privateCollections.reduce(0) { $0 + $1.tokensCount }
                        withAnimation {
                            self.privateCollections = collections
                            self.privateCollectionsLoaded = true
                            if self.pickedPrivateCollection &&
                                self.pickedCollection == nil && self.privateCollections.count > 0 {
                                self.pickedCollection = self.privateCollections[0]
                            }
                        }
                        if let lastCount = self.lastCollectionsCount,
                           observingCollectionsCount && collections.count > lastCount {
                            print("stopping observing")
                            self.stopObservingPrivateCollections()
                            self.purchaseFinished = true
                            self.purchasingInProgress = false
                            self.vibrationWorker.vibrate()
                            self.getAllowance()
                            self.getMinterBalance()
                        }
                        let newTokensCount = collections.reduce(0) { $0 + $1.tokensCount}
                        if oldTokensCount != newTokensCount {
                            self.privateNftsRequestTimer?.cancel()
                            self.getPrivateTokens()
                        }
                        if self.isAllPersonalInfoLoaded() {
                            self.backgroundManager.finishConnectBackgroundTask()
                        }
                    }
                }
            }
        }
    }
    
    func getPrivateTokens() {
        if let address = walletAccount {
            web3.getPrivateTokens(collections: privateCollections, address: address) { [weak self] tokens, error in
                if let error = error {
                    print("get private tokens error: \(error)")
                    //TODO: handle error?
                } else {
                    print("got private tokens: \(tokens)")
                    DispatchQueue.main.async {
                        let lastCount = self?.privateNfts.count
                        withAnimation {
                            self?.privateNfts = tokens
                            self?.privateNftsLoaded = true
                            self?.refreshingPrivateNfts = false
                        }
                        if let observing = self?.observingPrivateNftsCount,
                            let lastCount = lastCount,
                           observing && tokens.count > lastCount {
                            self?.stopObservingPrivateTokensCount()
                            self?.showMintFinishedSheet = true
                            self?.mintInProgress = false
                            self?.vibrationWorker.vibrate()
                        }
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
    
    func getAllowance() {
        if let address = walletAccount {
            print("requesting allowance")
            let accessTokenAddress = Constants.accessTokenAddress
            web3.getAllowance(owner: address, spender: accessTokenAddress) { [weak self] allowance, error in
                if let error = error {
                    print("get allowance error: \(error)")
                    //TODO: handle error?
                } else {
                    print("got allowance: \(allowance)")
                    withAnimation {
                        self?.allowance = allowance
                        self?.allowanceLoaded = true
                    }
                    if let loaded = self?.isAllPersonalInfoLoaded(), loaded {
                        self?.backgroundManager.finishConnectBackgroundTask()
                    }
                    if let observing = self?.observingAllowance, observing, allowance >= self?.privateCollectionPrice ?? 0 {
                        print("allowance updated")
                        self?.stopObservingAllowance()
                        withAnimation {
                            self?.purchasingInProgress = false
                        }
                        self?.vibrationWorker.vibrate()
                    }
                }
            }
        }
    }
    
    func publicMint(metaUrl: String, nftData: NftData) {
        do {
            let data = try JSONEncoder().encode(nftData)
            
            if connectedAddress != nil && isAgentAccount {
                web3.publicMintAgent(version: BigUInt(Constants.currentVersion),
                                     metaUrl: metaUrl,
                                     data: data) { [weak self] err in
                    if let err = err {
                        print("Tx error: \(err)")
                    } else {
                        self?.startObservingTokensCount()
                    }
                }
            } else {
                guard let data = web3.mintWithoutIdData(version: BigUInt(Constants.currentVersion),
                                                        metaUrl: metaUrl,
                                                        data: data) else {
                    //TODO: handle error
                    return
                }
                prepareAndSendTx(to: Constants.routerAddress, data: data, label: mintLabel)
            }
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
                
                if connectedAddress != nil && isAgentAccount {
                    web3.privateMintAgent(contractAddress: contract,
                                          to: mintTo,
                                          metaUrl: metaUrl,
                                          data: data) { [weak self] err in
                        if let err = err {
                            print("Tx error: \(err)")
                        } else {
                            self?.startObservingPrivateTokensCount()
                        }
                    }
                } else {
                    guard let data = web3.privateMintData(to: mintTo,
                                                          metaUrl: metaUrl,
                                                          data: data) else {
                        print("error getting data")
                        //TODO: handle error
                        return
                    }
                    prepareAndSendTx(to: contract, data: data, label: privateMintLabel)
                }
            } catch {
                print("Error encoding NftData: \(error)")
                //TODO: handle error
            }
        } else {
            print("Invalid address for private mint")
            //TODO: handle error
        }
    }
    
    func approveTokens() {
        withAnimation {
            self.purchasingInProgress = true
        }
        DispatchQueue.global(qos: .userInitiated).async { [self] in
            do {
                if connectedAddress != nil && isAgentAccount {
                    web3.approveAgent(spender: Constants.accessTokenAddress,
                                      amount: privateCollectionPrice-allowance) { [weak self] err in
                        if let err = err {
                            print("Tx error: \(err)")
                        } else {
                            self?.startObservingAllowance()
                        }
                    }
                } else {
                    guard let data = web3.approveData(spender: Constants.accessTokenAddress, amount: privateCollectionPrice-allowance) else {
                        //TODO: handle error
                        return
                    }
                    prepareAndSendTx(to: Constants.minterAddress, data: data, label: approveTokensLabel)
                }
            } catch {
                print("Error encoding approve data: \(error)")
                //TODO: handle error
            }
        }
    }
    
    func purchaseCollection(collectionData: PrivateCollectionData) {
        if let address = walletAccount {
            DispatchQueue.global(qos: .userInitiated).async { [self] in
                let filename = "\(collectionData.name.hashValue)_\(Date().timestamp())_meta.json"
                let meta = NftMeta(name: collectionData.name,
                                   description: "",
                                   image: Constants.ipfsMinterImage,
                                   properties: MetaProperties(id: nil, imageName: ""))
                HttpRequester.shared.uploadMetaToFilebase(meta: meta, filename: filename) { cid, error in
                    if let error = error {
                        print("Error uploading meta: \(error)")
                        return
                    }
                    if let cid = cid {
                        print("uploaded meta: \(cid)")
                        do {
                            let data = try JSONEncoder().encode(collectionData)
                            let salt = Tools.sha256(data: (address + "\(Date())").data(using: .utf8)!)
                            let metaLink = "ipfs://\(cid)"
                            if self.connectedAddress != nil && self.isAgentAccount {
                                self.web3.purchasePrivateCollectionAgent(salt: salt,
                                                                         name: collectionData.name,
                                                                         symbol: "",
                                                                         collectionMeta: metaLink,
                                                                         accessTokenMeta: Constants.ipfsAccessTokenMeta,
                                                                         data: data) { [weak self] err in
                                    if let err = err {
                                        print("Tx error: \(err)")
                                    } else {
                                        self?.startObservingPrivateCollections()
                                    }
                                }
                            } else {
                                guard let data = self.web3.purchasePrivateCollectionData(salt: salt,
                                                                                         name: collectionData.name,
                                                                                         symbol: "",
                                                                                         collectionMeta: metaLink,
                                                                                         accessTokenMeta: Constants.ipfsAccessTokenMeta,
                                                                                         data: data) else {
                                    //TODO: handle error
                                    return
                                }
                                DispatchQueue.main.async {
                                    withAnimation {
                                        self.purchasingInProgress = true
                                    }
                                    self.prepareAndSendTx(to: Constants.accessTokenAddress, data: data, label: self.purchaseCollectionLabel)
                                }
                            }
                        } catch {
                            print("Error encoding PrivatecollectionData: \(error)")
                            //TODO: handle error
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
                    if error.localizedDescription == "User rejected the transaction" {
                        print("user rejected")
                        DispatchQueue.main.async {
                            withAnimation {
                                switch label {
                                case self?.mintLabel, self?.privateMintLabel:
                                    self?.mintInProgress = false
                                case self?.approveTokensLabel, self?.purchaseCollectionLabel:
                                    self?.purchasingInProgress = false
                                default:
                                    print("unknown tx label: \(label)")
                                }
                            }
                        }
                    }
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
                    case self?.approveTokensLabel:
                        self?.startObservingAllowance()
                    case self?.purchaseCollectionLabel:
                        self?.startObservingPrivateCollections()
                    case self?.privateMintLabel:
                        self?.startObservingPrivateTokensCount()
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
        lastNftsCount = publicNfts.count
        nftsRequestTimer = Timer.publish(every: requestsInterval,
                              tolerance: requestsInterval/2,
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
    
    func startObservingPrivateTokensCount() {
        privateNftsRequestTimer?.cancel()
        observingPrivateNftsCount = true
        privateNftsRequestTimer = Timer.publish(every: requestsInterval,
                              tolerance: requestsInterval/2,
                              on: .main,
                              in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.getPrivateCollections()
        }
    }
    
    func stopObservingPrivateTokensCount() {
        observingPrivateNftsCount = false
        privateNftsRequestTimer?.cancel()
    }
    
    func startObservingPrivateCollections() {
        collectionsRequestTimer?.cancel()
        observingCollectionsCount = true
        lastCollectionsCount = privateCollections.count
        collectionsRequestTimer = Timer.publish(every: requestsInterval,
                              tolerance: requestsInterval/2,
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
    
    func startObservingBalance() {
        balanceRequestTimer?.cancel()
        observingBalance = true
        balanceRequestTimer = Timer.publish(every: requestsInterval,
                              tolerance: requestsInterval/2,
                              on: .main,
                              in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.getPolygonBalance()
        }
    }
    
    func stopObservingBalance() {
        observingBalance = false
        balanceRequestTimer?.cancel()
    }
    
    func startObservingAllowance() {
        allowanceRequestTimer?.cancel()
        observingAllowance = true
        allowanceRequestTimer = Timer.publish(every: requestsInterval,
                              tolerance: requestsInterval/2,
                              on: .main,
                              in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.getAllowance()
        }
    }
    
    func stopObservingAllowance() {
        observingAllowance = false
        allowanceRequestTimer?.cancel()
    }
    
    func refreshPublicNfts() {
        DispatchQueue.main.async {
            withAnimation {
                self.refreshingPublicNfts = true
            }
        }
        getPublicTokens(page: 0)
    }
    
    func refreshPrivateNfts() {
        DispatchQueue.main.async {
            withAnimation {
                self.refreshingPrivateNfts = true
            }
        }
        getPrivateTokens()
    }
}
