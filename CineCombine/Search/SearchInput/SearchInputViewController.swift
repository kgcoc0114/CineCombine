//
//  SearchInputViewController.swift
//  CineCombine
//
//  Created by KarenChiu on 2024/10/9.
//

import UIKit
import Combine

class SearchInputViewController: UIViewController {

    var cancellables = Set<AnyCancellable>()
    
    var viewModel: SearchInputViewModel

    let navigationBarBackgroundView = UIView()
    let navigationBar: UINavigationBar = {
        let navigationItem = UINavigationItem()
        let barAppearance = UINavigationBarAppearance()
        barAppearance.configureWithTransparentBackground()
        navigationItem.standardAppearance = barAppearance
        navigationItem.compactAppearance = barAppearance
        navigationItem.scrollEdgeAppearance = barAppearance

        let navigationBar = UINavigationBar(
            frame: CGRect(x: 0, y: 0, width: 300, height: 100)
        )
        navigationBar.setItems([navigationItem], animated: false)
        return navigationBar
    }()

    private(set) lazy var searchBar: UISearchBar = {
        let searchBar: UISearchBar
        searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: 320, height: 44))
        searchBar.placeholder = "Discover movies, actors & more"
        searchBar.sizeToFit()
        return searchBar
    }()

    private var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.keyboardDismissMode = .onDrag
        tableView.backgroundColor = .systemGroupedBackground
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    private lazy var errorView: ErrorView = {
        let view = ErrorView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.isHidden = true
        return view
    }()

    init(viewModel: SearchInputViewModel = SearchInputViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    //MARK: - UIViewController

    override func viewDidLoad() {

        super.viewDidLoad()

        setupBackgroundColor()
        setupNavigationBar()
        setupTableView()
        setupBindings()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        searchBar.setShowsScope(true, animated: false)
        searchBar.setNeedsLayout()
        searchBar.layoutIfNeeded()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchBar.setShowsCancelButton(true, animated: animated)
    }
}

extension SearchInputViewController {
    private func setupBindings() {
        viewModel.$sections
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.errorView.isHidden = true
                self.tableView.reloadData()
            }
            .store(in: &cancellables)

        viewModel.$error
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] error in
                self?.showErrorView(with: error)
            }
            .store(in: &cancellables)
    }

    private func setupNavigationBar() {
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(navigationBar)
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        navigationBar.topItem?.titleView = searchBar
        navigationBarBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(navigationBarBackgroundView, belowSubview: navigationBar)
        NSLayoutConstraint.activate([
            navigationBarBackgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            navigationBarBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBarBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navigationBarBackgroundView.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor),
        ])
        searchBar.delegate = self
    }

    private func setupBackgroundColor() {
        navigationBarBackgroundView.backgroundColor = .systemBackground
        navigationBar.tintColor = .gray
    }

    private func setupTableView() {
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: navigationBarBackgroundView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        tableView.register(SearchInputItemTableViewCell.self, forCellReuseIdentifier: SearchInputActorCellViewModel.identifier)
        tableView.register(SearchHistorySectionHeaderView.self, forHeaderFooterViewReuseIdentifier: SearchHistorySectionHeaderView.identifier)
        tableView.dataSource = self
        tableView.delegate = self
    }

    private func showErrorView(with error: SearchError) {
        if errorView.superview == nil {
            view.addSubview(errorView)
            NSLayoutConstraint.activate([
                errorView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
                errorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                errorView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                errorView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
        }
        
        self.errorView.configure(title: error.errorTitle,
                                 message: error.getErrorMessage(isResultPage: false))
        self.errorView.isHidden = false
    }
}

// MARK: - UITableViewDataSource
extension SearchInputViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = viewModel.sections[safe: section] else { return 0 }
        return viewModel.numberOfItems(in: section)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.sections.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cellViewModel = viewModel.item(at: indexPath),
           let cell = tableView.dequeueReusableCell(withIdentifier: SearchInputHashtagCellViewModel.identifier, for: indexPath) as? SearchInputItemTableViewCell {
            cell.configure(item: cellViewModel)
            return cell
        } else {
            return UITableViewCell()
        }
    }
}

extension SearchInputViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let section = viewModel.sections[safe: section],
              case .history = section,
              section.cellViewModels.isEmpty == false,
              let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: SearchHistorySectionHeaderView.identifier) as? SearchHistorySectionHeaderView else { return nil }
        view.clearButtonTapPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.viewModel.clearSearchHistory()
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
        return view
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = viewModel.sections[safe: indexPath.section],
              let cellViewModel = section.cellViewModels[safe: indexPath.row],
              let searchResultViewModel = cellViewModel.searchResultViewModel else { return }
        viewModel.saveSearchHistory(with: cellViewModel)
        let searchResultVC = SearchResultViewController(viewModel: searchResultViewModel)
        self.navigationController?.pushViewController(searchResultVC, animated: false)
    }
}

// MARK: - UISearchBarDelegate
extension SearchInputViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let trimmedSearchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        viewModel.searchText = trimmedSearchText
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else { return }
        let trimmedSearchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard trimmedSearchText.isEmpty == false else { return }
        let inputViewModel = SearchInputKeywordCellViewModel(keyword: trimmedSearchText)

        guard let searchResultViewModel = inputViewModel.searchResultViewModel else { return }
        searchBar.resignFirstResponder()

        viewModel.saveSearchHistory(with: inputViewModel)
        let searchResultVC = SearchResultViewController(viewModel: searchResultViewModel)
        self.navigationController?.pushViewController(searchResultVC, animated: false)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        viewModel.searchText = ""
        self.navigationController?.popViewController(animated: false)
    }
}
