//
//  ITunesEndpoint.swift
//  nesine-ios-casestudy
//
//  Created by Furkan Yıldırım on 14.11.2026.
//

import Foundation

enum ITunesEndpoint {
    case search(searchString: String)
}

extension ITunesEndpoint: Endpoint {
    var url: String {
        switch self {
        case .search:
            return "https://itunes.apple.com/search"
        }
    }

    var queryItems: [URLQueryItem] {
        switch self {
        case let .search(searchString):
            return [
                URLQueryItem(name: "term", value: searchString),
                URLQueryItem(name: "media", value: "software"),
                URLQueryItem(name: "limit", value: "50")
            ]
        }
    }
}
