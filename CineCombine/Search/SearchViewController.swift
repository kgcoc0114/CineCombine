//
//  SearchViewController.swift
//  CineCombine
//
//  Created by KarenChiu on 2024/10/9.
//

import UIKit
import Combine

class SearchViewModel {
}

class SearchViewController: UIViewController {

    var viewModel: SearchViewModel
    var cancellables = Set<AnyCancellable>()
    let searchBarTapPublisher = PassthroughSubject<String, Never>()
    let searchController = UISearchController()

    init(viewModel: SearchViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        setupLayout()
    }

    private func setupLayout() {
        setupNavigator()
        setupSearchBar()
    }

    private func setupNavigator() {
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = .systemBackground
        navigationBarAppearance.shadowColor = nil

        navigationItem.standardAppearance = navigationBarAppearance
        navigationItem.scrollEdgeAppearance = navigationBarAppearance
        navigationItem.compactAppearance = navigationBarAppearance
        navigationItem.compactScrollEdgeAppearance = navigationBarAppearance
        navigationItem.title = "Discover"
    }

    private func setupSearchBar() {
//        view.addSubview(searchBar)
//        searchBar.placeholder = "Search Keywords..."
        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Search Keywords..."
//        searchBar.sizeToFit()
        navigationItem.searchController = searchController

        searchBarTapPublisher
            .throttle(for: 0.5, scheduler: DispatchQueue.main, latest: false)
            .sink { [weak self] initialText in
                guard let self = self else { return }
                let searchInputVC = SearchInputViewController()
                self.navigationController?.pushViewController(searchInputVC, animated: false)
            }
            .store(in: &cancellables)
    }
}

extension SearchViewController: UISearchControllerDelegate, UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBarTapPublisher.send("")
        return false
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchBar.text = ""
        searchBarTapPublisher.send(searchText)
    }
}
