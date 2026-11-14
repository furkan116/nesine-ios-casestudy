//
//  SearchWorker.swift
//  nesine-ios-casestudy
//
//  Created by Furkan Yıldırım on 14.11.2026.
//

import Foundation

protocol SearchWorkerProtocol {
    func search(searchString: String, completion: @escaping (Result<[SoftwareApp], NetworkError>) -> Void)
}

final class SearchWorker: SearchWorkerProtocol {

    private let networkManager: NetworkManagerProtocol

    init(networkManager: NetworkManagerProtocol = NetworkManager()) {
        self.networkManager = networkManager
    }

    func search(searchString: String, completion: @escaping (Result<[SoftwareApp], NetworkError>) -> Void) {
        networkManager.request(ITunesEndpoint.search(searchString: searchString), responseType: SearchResponse.self) { result in
            let apps = result.map { response in
                (response.results ?? []).filter { !$0.screenshotURLs.isEmpty }
            }
            completion(apps)
        }
    }
}
