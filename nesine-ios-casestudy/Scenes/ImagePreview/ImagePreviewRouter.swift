//
//  ImagePreviewRouter.swift
//  nesine-ios-casestudy
//
//  Created by Furkan Yıldırım on 14.11.2026.
//

import UIKit

protocol ImagePreviewRoutingLogic {
    func dismiss()
}

protocol ImagePreviewDataPassing {
    var dataStore: ImagePreviewDataStore? { get }
}

final class ImagePreviewRouter: ImagePreviewRoutingLogic, ImagePreviewDataPassing {

    weak var viewController: UIViewController?
    var dataStore: ImagePreviewDataStore?

    func dismiss() {
        viewController?.dismiss(animated: true)
    }
}
