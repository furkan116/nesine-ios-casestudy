//
//  ImagePageViewController.swift
//  nesine-ios-casestudy
//
//  Created by Furkan Yıldırım on 14.11.2026.
//

import UIKit
import SnapKit

final class ImagePageViewController: UIViewController {

    let index: Int

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 4
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .darkGray
        return imageView
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.hidesWhenStopped = true
        return indicator
    }()

    init(index: Int) {
        self.index = index
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupViews()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        scrollView.setZoomScale(1, animated: false)
    }

    func setImage(_ image: UIImage?) {
        loadViewIfNeeded()
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
        scrollView.delegate = self

        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        view.addSubview(activityIndicator)

        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        imageView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.size.equalTo(scrollView.frameLayoutGuide)
        }

        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        if imageView.image == nil {
            activityIndicator.startAnimating()
        }
    }
}

extension ImagePageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
}
