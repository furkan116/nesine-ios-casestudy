//
//  NetworkError.swift
//  nesine-ios-casestudy
//
//  Created by Furkan Yıldırım on 14.11.2026.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case transport(URLError)
    case invalidResponse
    case httpStatus(Int)
    case decoding(Error)
}
