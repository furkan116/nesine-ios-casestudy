//
//  NetworkManagerProtocol.swift
//  nesine-ios-casestudy
//
//  Created by Furkan Yıldırım on 14.11.2026.
//

import Foundation

protocol NetworkManagerProtocol {
    func request<T: Decodable>(
        _ endpoint: Endpoint,
        responseType: T.Type,
        completion: @escaping (Result<T, NetworkError>) -> Void
    )
}
