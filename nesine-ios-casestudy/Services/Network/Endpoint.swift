//
//  Endpoint.swift
//  nesine-ios-casestudy
//
//  Created by Furkan Yıldırım on 14.11.2026.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
}

protocol Endpoint {
    var url: String { get }
    var method: HTTPMethod { get }
    var queryItems: [URLQueryItem] { get }
}

extension Endpoint {
    var method: HTTPMethod { .get }
    var queryItems: [URLQueryItem] { [] }

    func makeRequest() -> URLRequest? {
        guard var components = URLComponents(string: url) else { return nil }

        if !queryItems.isEmpty {
            components.queryItems = queryItems
            components.percentEncodedQuery = components.percentEncodedQuery?
                .replacingOccurrences(of: "+", with: "%2B")
        }

        guard let url = components.url else { return nil }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        return request
    }
}
