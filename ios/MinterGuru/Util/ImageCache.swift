//
//  ImageCache.swift
//  MinterGuru
//
//  Created by Lev Baklanov on 27.08.2022.
//

import Foundation
import Shallows
import SwiftUI

class ImageCache {
    
    static let shared = ImageCache()
    
    private let cache: Storage<String, UIImage>
    
    init() {
        let imagesCache = DiskStorage.folder("images-cache", in: .cachesDirectory)
            .mapValues(transformIn: { try UIImage(data: $0).unwrap() },
                       transformOut: { try $0.pngData().unwrap() })
            .usingStringKeys() // Storage<Filename, UIImage>
        
        let memoryCache = MemoryStorage<String, UIImage>().lowMemoryAware()
        cache = memoryCache.combined(with: imagesCache)
    }
    
    func save(_ image: UIImage, key: String) {
        print("saving to cache")
        cache.set(image, forKey: key) { result in
            print("cache save result: \(result)")
        }
    }
    
    func get(key: String, onResult: @escaping (UIImage?) -> ()) {
        cache.retrieve(forKey: key) { result in
            switch result {
            case .success(let image):
                onResult(image)
            case .failure(let error):
                print("error getting image from cache: \(error.localizedDescription)")
                onResult(nil)
            }
        }
    }
    
}

public final class MemoryWarningsAwareMemoryStorage<Key : Hashable, Value> : StorageProtocol {
    
    public let memoryStorage: MemoryStorage<Key, Value>
    
    public init(memoryStorage: MemoryStorage<Key, Value>) {
        self.memoryStorage = memoryStorage
        self.startListening()
    }
    
    private func startListening() {
        NotificationCenter.default.addObserver(forName: UIApplication.didReceiveMemoryWarningNotification,
                                               object: self,
                                               queue: nil) { (_) in
            self.memoryStorage.storage = [:]
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    public func retrieve(forKey key: Key, completion: @escaping (ShallowsResult<Value>) -> ()) {
        memoryStorage.retrieve(forKey: key, completion: completion)
    }
    
    public func set(_ value: Value, forKey key: Key, completion: @escaping (ShallowsResult<Void>) -> ()) {
        memoryStorage.set(value, forKey: key, completion: completion)
    }
    
}

extension MemoryStorage {
    
    public func lowMemoryAware() -> Storage<Key, Value> {
        return MemoryWarningsAwareMemoryStorage(memoryStorage: self).asStorage()
    }
    
}
