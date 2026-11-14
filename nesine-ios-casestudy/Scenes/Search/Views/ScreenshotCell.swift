//
//  ScreenshotCell.swift
//  nesine-ios-casestudy
//
//  Created by Furkan Yıldırım on 14.11.2026.
//

import UIKit
import SnapKit

final class ScreenshotCell: UICollectionViewCell {

    static let reuseIdentifier = "ScreenshotCell"

    var imageURL: URL?
    var image: UIImage?

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.tintColor = .tertiaryLabel
        return imageView
    }()

    private let activityIndicator = UIActivityIndicatorView(style: .medium)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageURL = nil
        image = nil
        imageView.image = nil
        activityIndicator.stopAnimating()
    }

    func configure(with url: URL) {
        imageURL = url
        image = nil
        imageView.image = nil
        activityIndicator.startAnimating()
    }

    func setImage(_ image: UIImage?) {
        self.image = image
        activityIndicator.stopAnimating()

        if let image = image {
            imageView.contentMode = .scaleAspectFit
            imageView.image = image
        } else {
            imageView.contentMode = .center
            imageView.image = UIImage(systemName: "photo")
        }
    }

    private func setupViews() {
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 8
        contentView.clipsToBounds = true

        contentView.addSubview(imageView)
        contentView.addSubview(activityIndicator)

        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
