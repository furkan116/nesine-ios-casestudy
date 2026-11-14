//
//  ITunesEndpointTests.swift
//  nesine-ios-casestudyTests
//
//  Created by Furkan Yıldırım on 15.11.2026.
//

import XCTest
@testable import nesine_ios_casestudy

final class ITunesEndpointTests: XCTestCase {

    func test_search_buildsSoftwareSearchURL() {
        let url = ITunesEndpoint.search(searchString: "c++ çiçek").makeRequest()?.url
        let components = url.flatMap { URLComponents(url: $0, resolvingAgainstBaseURL: false) }
        let queryItems = components?.queryItems ?? []

        XCTAssertEqual(components?.host, "itunes.apple.com")
        XCTAssertEqual(components?.path, "/search")
        XCTAssertTrue(queryItems.contains(URLQueryItem(name: "media", value: "software")))
        XCTAssertEqual(url?.absoluteString.contains("term=c%2B%2B%20%C3%A7i%C3%A7ek"), true)
    }
}
