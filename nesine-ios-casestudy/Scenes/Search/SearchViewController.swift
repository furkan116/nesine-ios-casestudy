//
//  SearchViewController.swift
//  nesine-ios-casestudy
//
//  Created by Furkan Yıldırım on 14.11.2026.
//

import UIKit
import SnapKit

protocol SearchDisplayLogic: AnyObject {
    func displayLoading()
    func displaySearchResults(apps: [SoftwareApp], emptyMessage: String?)
    func displayImage(url: URL, image: UIImage?)
    func displayError(message: String)
}

final class SearchViewController: UIViewController {

    var interactor: SearchBusinessLogic?
    var router: (SearchRoutingLogic & SearchDataPassing)?

    private var apps: [SoftwareApp] = []

    private let searchController = UISearchController(searchResultsController: nil)
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)
    private var searchIconView: UIView?
    private var lastSearchText = ""

    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        collectionView.backgroundColor = .systemBackground
        collectionView.keyboardDismissMode = .onDrag
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ScreenshotCell.self, forCellWithReuseIdentifier: ScreenshotCell.reuseIdentifier)
        collectionView.register(
            SectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SectionHeaderView.reuseIdentifier
        )
        return collectionView
    }()

    init() {
        super.init(nibName: nil, bundle: nil)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupSearchController()
        setupCollectionView()
        interactor?.search(searchString: "")
    }

    private func setup() {
        let imageDownloader = ImageDownloader()
        let interactor = SearchInteractor(worker: SearchWorker(), imageDownloader: imageDownloader)
        let presenter = SearchPresenter()
        let router = SearchRouter(imageDownloader: imageDownloader)
        self.interactor = interactor
        self.router = router
        interactor.presenter = presenter
        presenter.viewController = self
        router.viewController = self
        router.dataStore = interactor
    }

    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Uygulama ara...."
        searchIconView = searchController.searchBar.searchTextField.leftView
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }

    private func setLoading(_ isLoading: Bool) {
        let textField = searchController.searchBar.searchTextField
        if isLoading {
            loadingIndicator.startAnimating()
            textField.leftView = loadingIndicator
        } else {
            loadingIndicator.stopAnimating()
            textField.leftView = searchIconView
        }
    }

    private func setupCollectionView() {
        view.addSubview(collectionView)
        view.addSubview(emptyLabel)

        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        emptyLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(16)
        }
    }

    private func makeLayout() -> UICollectionViewLayout {
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        )

        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(widthDimension: .absolute(140), heightDimension: .absolute(250)),
            subitems: [item]
        )

        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(30)),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = 8
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 24, trailing: 16)
        section.boundarySupplementaryItems = [header]

        return UICollectionViewCompositionalLayout(section: section)
    }
}

extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard searchController.isActive else { return }
        interactor?.search(searchString: searchController.searchBar.text ?? "")
    }
}

extension SearchViewController: UISearchControllerDelegate {
    func willDismissSearchController(_ searchController: UISearchController) {
        lastSearchText = searchController.searchBar.text ?? ""
    }

    func didDismissSearchController(_ searchController: UISearchController) {
        searchController.searchBar.text = lastSearchText
    }
}

extension SearchViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        apps.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        apps[section].screenshotURLs.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ScreenshotCell.reuseIdentifier,
            for: indexPath
        ) as? ScreenshotCell else {
            return UICollectionViewCell()
        }

        cell.configure(with: apps[indexPath.section].screenshotURLs[indexPath.item])
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: SectionHeaderView.reuseIdentifier,
            for: indexPath
        ) as? SectionHeaderView else {
            return UICollectionReusableView()
        }

        header.configure(title: apps[indexPath.section].trackName ?? "")
        return header
    }
}

extension SearchViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? ScreenshotCell, cell.image == nil, let url = cell.imageURL else { return }
        interactor?.loadImage(url: url)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        interactor?.selectImage(section: indexPath.section, index: indexPath.item)
        router?.routeToImagePreview()
    }
}

extension SearchViewController: SearchDisplayLogic {
    func displayLoading() {
        setLoading(true)
    }

    func displaySearchResults(apps: [SoftwareApp], emptyMessage: String?) {
        setLoading(false)
        self.apps = apps
        emptyLabel.text = emptyMessage
        collectionView.reloadData()
        collectionView.setContentOffset(CGPoint(x: 0, y: -collectionView.adjustedContentInset.top), animated: false)
    }

    func displayImage(url: URL, image: UIImage?) {
        collectionView.visibleCells
            .compactMap { $0 as? ScreenshotCell }
            .filter { $0.imageURL == url }
            .forEach { $0.setImage(image) }
    }

    func displayError(message: String) {
        setLoading(false)

        let presentingController = presentedViewController ?? self
        guard !(presentingController is UIAlertController) else { return }

        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        presentingController.present(alert, animated: true)
    }
}
