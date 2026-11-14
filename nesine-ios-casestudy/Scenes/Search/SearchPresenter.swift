//
//  SearchPresenter.swift
//  nesine-ios-casestudy
//
//  Created by Furkan Yıldırım on 14.11.2026.
//

import UIKit

protocol SearchPresentationLogic {
    func presentLoading()
    func presentSearchResults(apps: [SoftwareApp], searchString: String)
    func presentImage(url: URL, image: UIImage?)
    func presentError(_ error: NetworkError)
}

final class SearchPresenter: SearchPresentationLogic {

    weak var viewController: SearchDisplayLogic?

    func presentLoading() {
        viewController?.displayLoading()
    }

    func presentSearchResults(apps: [SoftwareApp], searchString: String) {
        var emptyMessage: String?
        if apps.isEmpty {
            emptyMessage = searchString.isEmpty ? "Arama yapın." : "Sonuç bulunmadı."
        }

        viewController?.displaySearchResults(apps: apps, emptyMessage: emptyMessage)
    }

    func presentImage(url: URL, image: UIImage?) {
        viewController?.displayImage(url: url, image: image)
    }

    func presentError(_ error: NetworkError) {
        let message: String
        switch error {
        case .transport(let urlError) where urlError.code == .notConnectedToInternet:
            message = "İnternet bağlantısı yok."
        default:
            message = "Bir hata oluştu. Lütfen tekrar deneyin."
        }
        viewController?.displayError(message: message)
    }
}
