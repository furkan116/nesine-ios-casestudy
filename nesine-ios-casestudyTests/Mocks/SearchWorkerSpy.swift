//
//  SearchWorkerSpy.swift
//  nesine-ios-casestudyTests
//
//  Created by Furkan Yıldırım on 15.11.2026.
//

import Foundation
@testable import nesine_ios_casestudy

final class SearchWorkerSpy: SearchWorkerProtocol {

    var searchedStrings: [String] = []
    private var completions: [(Result<[SoftwareApp], NetworkError>) -> Void] = []

    func search(searchString: String, completion: @escaping (Result<[SoftwareApp], NetworkError>) -> Void) {
        searchedStrings.append(searchString)
        completions.append(completion)
    }

    func complete(at index: Int, with result: Result<[SoftwareApp], NetworkError>) {
        guard completions.indices.contains(index) else { return }
        completions[index](result)
    }
}
