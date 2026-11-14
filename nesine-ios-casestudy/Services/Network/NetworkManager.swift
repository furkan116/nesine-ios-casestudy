//
//  NetworkManager.swift
//  nesine-ios-casestudy
//
//  Created by Furkan Yıldırım on 14.11.2026.
//

import Foundation

final class NetworkManager: NetworkManagerProtocol {

    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared, decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
    }

    func request<T: Decodable>(
        _ endpoint: Endpoint,
        responseType: T.Type,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        guard let request = endpoint.makeRequest() else {
            completion(.failure(.invalidURL))
            return
        }

        session.dataTask(with: request) { [decoder] data, response, error in
            if let error = error as? URLError {
                completion(.failure(.transport(error)))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, let data = data else {
                completion(.failure(.invalidResponse))
                return
            }

            guard (200..<300).contains(httpResponse.statusCode) else {
                completion(.failure(.httpStatus(httpResponse.statusCode)))
                return
            }

            do {
                completion(.success(try decoder.decode(T.self, from: data)))
            } catch {
                completion(.failure(.decoding(error)))
            }
        }.resume()
    }
}
