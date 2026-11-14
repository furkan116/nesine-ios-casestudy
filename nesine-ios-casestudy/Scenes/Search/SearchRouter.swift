//
//  SearchRouter.swift
//  nesine-ios-casestudy
//
//  Created by Furkan Yıldırım on 14.11.2026.
//

import UIKit

protocol SearchRoutingLogic {
    func routeToImagePreview()
}

protocol SearchDataPassing {
    var dataStore: SearchDataStore? { get }
}

final class SearchRouter: SearchRoutingLogic, SearchDataPassing {

    weak var viewController: UIViewController?
    var dataStore: SearchDataStore?

    private let imageDownloader: ImageDownloaderProtocol

    init(imageDownloader: ImageDownloaderProtocol) {
        self.imageDownloader = imageDownloader
    }

    func routeToImagePreview() {
        guard let dataStore = dataStore, !dataStore.selectedImageURLs.isEmpty else { return }

        let destination = ImagePreviewViewController(imageDownloader: imageDownloader)
        destination.router?.dataStore?.imageURLs = dataStore.selectedImageURLs
        destination.router?.dataStore?.selectedIndex = dataStore.selectedImageIndex
        destination.modalPresentationStyle = .fullScreen
        viewController?.present(destination, animated: true)
    }
}
