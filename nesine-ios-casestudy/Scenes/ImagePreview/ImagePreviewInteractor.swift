//
//  ImagePreviewInteractor.swift
//  nesine-ios-casestudy
//
//  Created by Furkan Yıldırım on 14.11.2026.
//

import Foundation

protocol ImagePreviewBusinessLogic {
    func loadImages()
}

protocol ImagePreviewDataStore: AnyObject {
    var imageURLs: [URL] { get set }
    var selectedIndex: Int { get set }
}

final class ImagePreviewInteractor: ImagePreviewBusinessLogic, ImagePreviewDataStore {

    var presenter: ImagePreviewPresentationLogic?
    var imageURLs: [URL] = []
    var selectedIndex = 0

    private let imageDownloader: ImageDownloaderProtocol

    init(imageDownloader: ImageDownloaderProtocol) {
        self.imageDownloader = imageDownloader
    }

    func loadImages() {
        let index = min(max(selectedIndex, 0), max(imageURLs.count - 1, 0))
        presenter?.presentImages(count: imageURLs.count, selectedIndex: index)

        imageURLs.enumerated().forEach { imageIndex, url in
            imageDownloader.downloadImage(from: url) { [weak self] image in
                DispatchQueue.main.async {
                    self?.presenter?.presentImage(index: imageIndex, image: image)
                }
            }
        }
    }
}
