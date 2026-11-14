//
//  ImageDownloaderProtocol.swift
//  nesine-ios-casestudy
//
//  Created by Furkan Yıldırım on 14.11.2026.
//

import UIKit

protocol ImageDownloaderProtocol {
    func downloadImage(from url: URL, completion: @escaping (UIImage?) -> Void)
    func cancelAll()
}
