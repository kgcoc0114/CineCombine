//
//  SearchResultViewController.swift
//  CineCombine
//
//  Created by KarenChiu on 2024/10/22.
//

import UIKit
import Combine

class SearchResultViewController: UIViewController {
    
    // MARK: - UI Components
    private lazy var errorView: ErrorView = {
        let view = ErrorView()
        view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(view)
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: (self.navigationController?.navigationBar.bottomAnchor)!),
            view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
        view.isHidden = true
        return view
    }()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: viewModel.layout.layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(refreshControlValueChanged(_:)), for: .valueChanged )
        return control
    }()
    
    private lazy var switchLayoutButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            image: viewModel.layout.buttonIcon,
            style: .plain,
            target: self,
            action: #selector(switchLayoutButtonTapped)
        )
        return button
    }()
    // MARK: - Properties
    
    private var cancellables = Set<AnyCancellable>()
    private let viewModel: SearchResultViewModel
    
    init(viewModel: SearchResultViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupNavigationBar()
        setupCollectionView()
        switchLayoutButton.isHidden = true
        setupBinding()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        self.viewModel.refresh()
    }
    
    // MARK: - Private Methods
    
    private func setupNavigationBar() {
        self.title = viewModel.navigationTitle
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationItem.rightBarButtonItem = switchLayoutButton
    }
    
    private func setupCollectionView() {
        viewModel.configureDataSource(collectionView: collectionView)
        collectionView.delegate = self
        collectionView.refreshControl = refreshControl
                                 
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }

    private func setupBinding() {
        // API Loading status
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                guard isLoading == false else { return }
                self?.collectionView.refreshControl?.endRefreshing()
            }
            .store(in: &cancellables)

        viewModel.$error
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] error in
                self?.showErrorView(with: error)
            }
            .store(in: &cancellables)

        viewModel.$layout
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newLayout in
                self?.collectionView.setCollectionViewLayout(newLayout.layout, animated: false)
                self?.switchLayoutButton.image = newLayout.buttonIcon
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)

        viewModel.$canSwitchLayout
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newValue in
                self?.switchLayoutButton.isHidden = newValue == false
            }
            .store(in: &cancellables)
    }

    private func showErrorView(with error: SearchError) {
        self.errorView.configure(title: error.errorTitle, message: error.getErrorMessage()) { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        self.errorView.isHidden = false
    }

    @objc private func refreshControlValueChanged(_ sender: UIRefreshControl) {
        viewModel.refresh()
    }

    @objc private func switchLayoutButtonTapped(_ sender: UIRefreshControl) {
        viewModel.updateLayoutType()

    }
}

extension SearchResultViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        viewModel.loadMoreIfNeeded(at: indexPath)
    }
}
