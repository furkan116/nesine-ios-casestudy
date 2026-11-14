//
//  ImagePreviewViewController.swift
//  nesine-ios-casestudy
//
//  Created by Furkan Yıldırım on 14.11.2026.
//

import UIKit
import SnapKit

protocol ImagePreviewDisplayLogic: AnyObject {
    func displayImages(count: Int, selectedIndex: Int)
    func displayImage(index: Int, image: UIImage?)
}

final class ImagePreviewViewController: UIViewController {

    var interactor: ImagePreviewBusinessLogic?
    var router: (ImagePreviewRoutingLogic & ImagePreviewDataPassing)?

    private var pages: [ImagePageViewController] = []

    private let pageViewController = UIPageViewController(
        transitionStyle: .scroll,
        navigationOrientation: .horizontal,
        options: [.interPageSpacing: 16]
    )

    private let pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.hidesForSinglePage = true
        pageControl.isUserInteractionEnabled = false
        return pageControl
    }()

    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        button.layer.cornerRadius = 20
        return button
    }()

    override var prefersStatusBarHidden: Bool {
        true
    }

    init(imageDownloader: ImageDownloaderProtocol) {
        super.init(nibName: nil, bundle: nil)
        setup(imageDownloader: imageDownloader)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupViews()
        interactor?.loadImages()
    }

    private func setup(imageDownloader: ImageDownloaderProtocol) {
        let interactor = ImagePreviewInteractor(imageDownloader: imageDownloader)
        let presenter = ImagePreviewPresenter()
        let router = ImagePreviewRouter()
        self.interactor = interactor
        self.router = router
        interactor.presenter = presenter
        presenter.viewController = self
        router.viewController = self
        router.dataStore = interactor
    }

    private func setupViews() {
        pageViewController.dataSource = self
        pageViewController.delegate = self
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)

        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)
        view.addSubview(pageControl)
        view.addSubview(closeButton)

        pageViewController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        pageControl.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(8)
        }

        closeButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.trailing.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.size.equalTo(40)
        }
    }

    @objc private func closeButtonTapped() {
        router?.dismiss()
    }
}

extension ImagePreviewViewController: UIPageViewControllerDataSource {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let page = viewController as? ImagePageViewController, page.index > 0 else { return nil }
        return pages[page.index - 1]
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let page = viewController as? ImagePageViewController, page.index < pages.count - 1 else { return nil }
        return pages[page.index + 1]
    }
}

extension ImagePreviewViewController: UIPageViewControllerDelegate {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        guard completed, let page = pageViewController.viewControllers?.first as? ImagePageViewController else { return }
        pageControl.currentPage = page.index
    }
}

extension ImagePreviewViewController: ImagePreviewDisplayLogic {
    func displayImages(count: Int, selectedIndex: Int) {
        pages = (0..<count).map { ImagePageViewController(index: $0) }
        pageControl.numberOfPages = count
        pageControl.currentPage = selectedIndex

        guard pages.indices.contains(selectedIndex) else { return }
        pageViewController.setViewControllers([pages[selectedIndex]], direction: .forward, animated: false)
    }

    func displayImage(index: Int, image: UIImage?) {
        guard pages.indices.contains(index) else { return }
        pages[index].setImage(image)
    }
}
