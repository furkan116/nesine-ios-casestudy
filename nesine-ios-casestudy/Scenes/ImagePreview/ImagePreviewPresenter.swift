//
//  ImagePreviewPresenter.swift
//  nesine-ios-casestudy
//
//  Created by Furkan Yıldırım on 14.11.2026.
//

import UIKit

protocol ImagePreviewPresentationLogic {
    func presentImages(count: Int, selectedIndex: Int)
    func presentImage(index: Int, image: UIImage?)
}

final class ImagePreviewPresenter: ImagePreviewPresentationLogic {

    weak var viewController: ImagePreviewDisplayLogic?

    func presentImages(count: Int, selectedIndex: Int) {
        viewController?.displayImages(count: count, selectedIndex: selectedIndex)
    }

    func presentImage(index: Int, image: UIImage?) {
        viewController?.displayImage(index: index, image: image)
    }
}
