//
//  ImageDownloader.swift
//  nesine-ios-casestudy
//
//  Created by Furkan Yıldırım on 14.11.2026.
//

import UIKit
import ImageIO

final class ImageDownloader: ImageDownloaderProtocol {

    private let session: URLSession
    private let cache = NSCache<NSURL, NSData>()
    private let queue = DispatchQueue(label: "com.furkanyildirim.nesine-ios-casestudy.image-downloader")
    private let semaphore: DispatchSemaphore
    private let lock = NSLock()
    private var generation = 0

    init(session: URLSession = URLSession(configuration: .default), maxConcurrentDownloads: Int = 3) {
        self.session = session
        self.semaphore = DispatchSemaphore(value: maxConcurrentDownloads)
        cache.totalCostLimit = 100 * 1024 * 1024
    }

    func downloadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        if let data = cache.object(forKey: url as NSURL) {
            DispatchQueue.global(qos: .userInitiated).async {
                completion(Self.decodeImage(from: data as Data))
            }
            return
        }

        let requestGeneration = currentGeneration()

        queue.async { [weak self] in
            guard let self = self else { return }
            self.semaphore.wait()

            guard requestGeneration == self.currentGeneration() else {
                self.semaphore.signal()
                return
            }

            let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData)

            self.session.dataTask(with: request) { data, _, error in
                defer { self.semaphore.signal() }

                if (error as? URLError)?.code == .cancelled {
                    return
                }

                guard let data = data, let image = Self.decodeImage(from: data) else {
                    completion(nil)
                    return
                }

                self.cache.setObject(data as NSData, forKey: url as NSURL, cost: data.count)
                completion(image)
            }.resume()
        }
    }

    func cancelAll() {
        lock.lock()
        generation += 1
        lock.unlock()

        session.getAllTasks { tasks in
            tasks.forEach { $0.cancel() }
        }
    }

    private func currentGeneration() -> Int {
        lock.lock()
        defer { lock.unlock() }
        return generation
    }

    private static func decodeImage(from data: Data) -> UIImage? {
        let options = [kCGImageSourceShouldCacheImmediately: true] as CFDictionary
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let cgImage = CGImageSourceCreateImageAtIndex(source, 0, options) else {
            return nil
        }
        return UIImage(cgImage: cgImage)
    }
}
