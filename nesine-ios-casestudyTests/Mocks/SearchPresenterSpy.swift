//
//  SearchPresenterSpy.swift
//  nesine-ios-casestudyTests
//
//  Created by Furkan Yıldırım on 15.11.2026.
//

import UIKit
@testable import nesine_ios_casestudy

final class SearchPresenterSpy: SearchPresentationLogic {

    var presentedApps: [[SoftwareApp]] = []
    var presentedSearchStrings: [String] = []
    var presentedErrors: [NetworkError] = []
    var onPresentSearchResults: (() -> Void)?
    var onPresentError: (() -> Void)?

    func presentLoading() {}

    func presentSearchResults(apps: [SoftwareApp], searchString: String) {
        presentedApps.append(apps)
        presentedSearchStrings.append(searchString)
        onPresentSearchResults?()
    }

    func presentImage(url: URL, image: UIImage?) {}

    func presentError(_ error: NetworkError) {
        presentedErrors.append(error)
        onPresentError?()
    }
}
