//
//  ImageDownloaderSpy.swift
//  nesine-ios-casestudyTests
//
//  Created by Furkan Yıldırım on 15.11.2026.
//

import UIKit
@testable import nesine_ios_casestudy

final class ImageDownloaderSpy: ImageDownloaderProtocol {

    var requestedURLs: [URL] = []
    var cancelAllCallCount = 0

    func downloadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        requestedURLs.append(url)
    }

    func cancelAll() {
        cancelAllCallCount += 1
    }
}
