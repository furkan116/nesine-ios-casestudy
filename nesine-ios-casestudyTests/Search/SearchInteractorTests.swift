//
//  SearchInteractorTests.swift
//  nesine-ios-casestudyTests
//
//  Created by Furkan Yıldırım on 15.11.2026.
//

import XCTest
@testable import nesine_ios_casestudy

final class SearchInteractorTests: XCTestCase {

    private let worker = SearchWorkerSpy()
    private let imageDownloader = ImageDownloaderSpy()
    private let presenter = SearchPresenterSpy()
    private let debounceClock = TestDebounceClock()

    func test_search_withEmptySearchString_presentsEmptyResultsWithoutCallingWorker() {
        let sut = makeSUT()

        sut.search(searchString: "   ")

        XCTAssertTrue(worker.searchedStrings.isEmpty)
        XCTAssertEqual(presenter.presentedApps.count, 1)
        XCTAssertEqual(presenter.presentedApps.first?.isEmpty, true)
    }

    func test_search_whenTypedQuickly_searchesOnlyLastSearchString() {
        let sut = makeSUT()

        sut.search(searchString: "i")
        debounceClock.advance(by: 0.2)
        sut.search(searchString: "in")
        debounceClock.advance(by: 0.2)
        sut.search(searchString: "ins")

        debounceClock.advance(by: 0.39)
        XCTAssertTrue(worker.searchedStrings.isEmpty)

        debounceClock.advance(by: 0.02)
        XCTAssertEqual(worker.searchedStrings, ["ins"])
    }

    func test_search_whenSucceeds_downloadsAllScreenshots() {
        let sut = makeSUT()
        let apps = [
            makeApp(screenshotCount: 3),
            makeApp(screenshotCount: 2)
        ]

        search("instagram", with: sut)
        let presented = expectation(description: "results presented")
        presenter.onPresentSearchResults = { presented.fulfill() }

        worker.complete(at: 0, with: .success(apps))

        wait(for: [presented], timeout: 1)
        XCTAssertEqual(presenter.presentedApps.first?.count, 2)
        XCTAssertEqual(imageDownloader.requestedURLs.count, 5)
    }

    func test_search_ignoresResultOfPreviousSearchString() {
        let sut = makeSUT()
        search("insta", with: sut)
        search("instagram", with: sut)
        let presented = expectation(description: "results presented")
        presenter.onPresentSearchResults = { presented.fulfill() }

        worker.complete(at: 0, with: .success([makeApp(screenshotCount: 1)]))
        worker.complete(at: 1, with: .success([]))

        wait(for: [presented], timeout: 1)
        XCTAssertEqual(presenter.presentedApps.count, 1)
        XCTAssertEqual(presenter.presentedSearchStrings.first, "instagram")
        XCTAssertTrue(imageDownloader.requestedURLs.isEmpty)
    }

    func test_search_whenFails_presentsError() {
        let sut = makeSUT()
        search("instagram", with: sut)
        let presented = expectation(description: "error presented")
        presenter.onPresentError = { presented.fulfill() }

        worker.complete(at: 0, with: .failure(.invalidResponse))

        wait(for: [presented], timeout: 1)
        XCTAssertEqual(presenter.presentedErrors.count, 1)
        XCTAssertTrue(presenter.presentedApps.isEmpty)
    }

    private func makeSUT() -> SearchInteractor {
        let sut = SearchInteractor(worker: worker, imageDownloader: imageDownloader, debounceClock: debounceClock)
        sut.presenter = presenter
        return sut
    }

    private func search(_ searchString: String, with sut: SearchInteractor) {
        sut.search(searchString: searchString)
        debounceClock.advance(by: 0.4)
    }

    private func makeApp(screenshotCount: Int) -> SoftwareApp {
        let urls = (0..<screenshotCount).map { "https://example.com/\(UUID().uuidString)/\($0).jpg" }
        return SoftwareApp(trackId: Int.random(in: 1...1000), trackName: "App", screenshotUrls: urls)
    }
}
