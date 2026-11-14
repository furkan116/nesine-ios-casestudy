//
//  URLProtocolStub.swift
//  nesine-ios-casestudyTests
//
//  Created by Furkan Yıldırım on 15.11.2026.
//

import UIKit

final class URLProtocolStub: URLProtocol {

    static var responseDelay: TimeInterval = 0.1
    private static let lock = NSLock()
    private static var activeRequestCount = 0
    private static var _maxActiveRequestCount = 0

    static var maxActiveRequestCount: Int {
        lock.lock()
        defer { lock.unlock() }
        return _maxActiveRequestCount
    }

    static func reset() {
        lock.lock()
        activeRequestCount = 0
        _maxActiveRequestCount = 0
        lock.unlock()
    }

    private static let imageData: Data = {
        UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1)).pngData { context in
            UIColor.red.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        }
    }()

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        Self.lock.lock()
        Self.activeRequestCount += 1
        Self._maxActiveRequestCount = max(Self._maxActiveRequestCount, Self.activeRequestCount)
        Self.lock.unlock()

        DispatchQueue.global().asyncAfter(deadline: .now() + Self.responseDelay) { [weak self] in
            guard let self = self, let url = self.request.url else { return }

            Self.lock.lock()
            Self.activeRequestCount -= 1
            Self.lock.unlock()

            if let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil) {
                self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            self.client?.urlProtocol(self, didLoad: Self.imageData)
            self.client?.urlProtocolDidFinishLoading(self)
        }
    }

    override func stopLoading() {}
}
