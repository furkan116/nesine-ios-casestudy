//
//  ImageDownloaderTests.swift
//  nesine-ios-casestudyTests
//
//  Created by Furkan Yıldırım on 15.11.2026.
//

import XCTest
@testable import nesine_ios_casestudy

final class ImageDownloaderTests: XCTestCase {

    override func setUp() {
        super.setUp()
        URLProtocolStub.reset()
    }

    func test_downloadImage_runsAtMostThreeDownloadsConcurrently() {
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [URLProtocolStub.self]
        let sut = ImageDownloader(session: URLSession(configuration: configuration))

        let urls = (0..<10).compactMap { URL(string: "https://example.com/\($0).png") }
        let finished = expectation(description: "all downloads finished")
        finished.expectedFulfillmentCount = urls.count

        urls.forEach { url in
            sut.downloadImage(from: url) { _ in
                finished.fulfill()
            }
        }

        wait(for: [finished], timeout: 5)
        XCTAssertEqual(URLProtocolStub.maxActiveRequestCount, 3)
    }
}
