//
//  SearchInteractor.swift
//  nesine-ios-casestudy
//
//  Created by Furkan Yıldırım on 14.11.2026.
//

import UIKit

protocol SearchBusinessLogic {
    func search(searchString: String)
    func loadImage(url: URL)
    func selectImage(section: Int, index: Int)
}

protocol SearchDataStore {
    var selectedImageURLs: [URL] { get }
    var selectedImageIndex: Int { get }
}

final class SearchInteractor: SearchBusinessLogic, SearchDataStore {

    var presenter: SearchPresentationLogic?
    var selectedImageURLs: [URL] = []
    var selectedImageIndex = 0

    private let worker: SearchWorkerProtocol
    private let imageDownloader: ImageDownloaderProtocol
    private let debounceClock: DebounceClockProtocol
    private let debounceInterval: TimeInterval

    private var debounceWorkItem: DispatchWorkItem?
    private var currentSearchString = ""
    private var pendingURLs = Set<URL>()
    private var apps: [SoftwareApp] = []

    init(
        worker: SearchWorkerProtocol,
        imageDownloader: ImageDownloaderProtocol,
        debounceClock: DebounceClockProtocol = DebounceClock(),
        debounceInterval: TimeInterval = 0.4
    ) {
        self.worker = worker
        self.imageDownloader = imageDownloader
        self.debounceClock = debounceClock
        self.debounceInterval = debounceInterval
    }

    func search(searchString: String) {
        let searchString = searchString.trimmingCharacters(in: .whitespacesAndNewlines)
        debounceWorkItem?.cancel()

        guard !searchString.isEmpty else {
            reset()
            presenter?.presentSearchResults(apps: [], searchString: searchString)
            return
        }

        guard searchString != currentSearchString else { return }

        let workItem = DispatchWorkItem { [weak self] in
            self?.performSearch(searchString: searchString)
        }
        debounceWorkItem = workItem
        debounceClock.schedule(after: debounceInterval, workItem: workItem)
    }

    func loadImage(url: URL) {
        guard !pendingURLs.contains(url) else { return }
        downloadImage(from: url)
    }

    func selectImage(section: Int, index: Int) {
        guard apps.indices.contains(section) else { return }
        selectedImageURLs = apps[section].screenshotURLs
        selectedImageIndex = index
    }

    private func performSearch(searchString: String) {
        reset()
        currentSearchString = searchString
        presenter?.presentLoading()

        worker.search(searchString: searchString) { [weak self] result in
            DispatchQueue.main.async {
                self?.handleSearchResult(result, searchString: searchString)
            }
        }
    }

    private func handleSearchResult(_ result: Result<[SoftwareApp], NetworkError>, searchString: String) {
        guard searchString == currentSearchString else { return }

        switch result {
        case .success(let apps):
            self.apps = apps
            presenter?.presentSearchResults(apps: apps, searchString: searchString)
            downloadAllImages(of: apps)
        case .failure(let error):
            currentSearchString = ""
            presenter?.presentError(error)
        }
    }

    private func downloadAllImages(of apps: [SoftwareApp]) {
        let urls = apps.flatMap { $0.screenshotURLs }
        pendingURLs = Set(urls)
        urls.forEach { downloadImage(from: $0) }
    }

    private func downloadImage(from url: URL) {
        imageDownloader.downloadImage(from: url) { [weak self] image in
            DispatchQueue.main.async {
                self?.pendingURLs.remove(url)
                self?.presenter?.presentImage(url: url, image: image)
            }
        }
    }

    private func reset() {
        imageDownloader.cancelAll()
        pendingURLs.removeAll()
        apps.removeAll()
        currentSearchString = ""
    }
}
