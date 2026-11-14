//
//  SearchResponse.swift
//  nesine-ios-casestudy
//
//  Created by Furkan Yıldırım on 14.11.2026.
//

import Foundation

struct SearchResponse: Decodable {
    let resultCount: Int?
    let results: [SoftwareApp]?
}

struct SoftwareApp: Decodable {
    let trackId: Int?
    let trackName: String?
    let screenshotUrls: [String]?

    var screenshotURLs: [URL] {
        (screenshotUrls ?? []).compactMap(URL.init(string:))
    }
}
