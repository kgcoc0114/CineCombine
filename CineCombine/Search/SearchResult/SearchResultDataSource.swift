//
//  SearchResultDataSource.swift
//  CineCombine
//
//  Created by KarenChiu on 2024/10/31.
//

import Foundation
import UIKit

final class SearchResultDataSource {
    // Type aliases
    typealias DataSource = UICollectionViewDiffableDataSource<Section, SectionItem>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, SectionItem>

    private var diffableDataSource: DataSource?
    private var layout: SearchResultLayoutType

    init(layout: SearchResultLayoutType) {
        self.layout = layout
    }

    func configure(for collectionView: UICollectionView) {
        collectionView.register(SearchResultListCollectionViewCell.self, forCellWithReuseIdentifier: SearchResultLayoutType.list.identifier)
        collectionView.register(SearchResultCardCollectionViewCell.self, forCellWithReuseIdentifier: SearchResultLayoutType.card.identifier)
        collectionView.register(SearchInputItemCollectionViewCell.self, forCellWithReuseIdentifier: SearchInputItemCollectionViewCell.reuseIdentifier)

        diffableDataSource = DataSource(collectionView: collectionView,
                                        cellProvider: { [weak self] collectionView, indexPath, item in
            guard let self = self else { return UICollectionViewCell() }
            return self.configureCellForItem(with: item, at: indexPath, for: collectionView)
        })

        collectionView.dataSource = diffableDataSource

        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        diffableDataSource?.apply(snapshot,animatingDifferences: false)
    }

    private func configureCellForItem(with item: SearchResultDataSource.SectionItem,
                                      at indexPath: IndexPath,
                                      for collectionView: UICollectionView) -> UICollectionViewCell {
        switch item {
        case .searchResult(let viewModel):
            return configureSearchResultCell(with: viewModel, at: indexPath, for: collectionView)
        case .searchInput(let viewModel):
            return configureSearchInputCell(with: viewModel, at: indexPath, for: collectionView)
        }
    }

    private func configureSearchResultCell(with viewModel: SearchResultCellViewModelProtocol,
                                           at indexPath: IndexPath,
                                           for collectionView: UICollectionView) -> UICollectionViewCell {
        switch self.layout {
        case .list:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.layout.identifier,
                                                                for: indexPath) as? SearchResultListCollectionViewCell
            else { return UICollectionViewCell() }

            cell.configure(item: viewModel, indexPath: indexPath)
            return cell
        case .card:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.layout.identifier,
                                                                for: indexPath) as? SearchResultCardCollectionViewCell
            else { return UICollectionViewCell() }

            cell.configure(item: viewModel, indexPath: indexPath)
            return cell
        }
    }

    private func configureSearchInputCell(with viewModel: SearchInputItemCellViewModelProtocol,
                                          at indexPath: IndexPath,
                                          for collectionView: UICollectionView) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchInputItemCollectionViewCell.reuseIdentifier,
                                                            for: indexPath) as? SearchInputItemCollectionViewCell
        else { return UICollectionViewCell() }
        cell.configure(item: viewModel)
        return cell
    }

    func applySnapshot(viewModels: [CellViewModelProtocol]) {
        guard let diffableDataSource = diffableDataSource else { return }
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        let items = viewModels.compactMap { viewModel in
            if let viewModel = viewModel as? SearchResultCellViewModelProtocol {
                return SectionItem.searchResult(viewModel)
            } else if let viewModel = viewModel as? SearchInputItemCellViewModelProtocol {
                return SectionItem.searchInput(viewModel)
            }
            return nil
        }
        snapshot.appendItems(items)
        diffableDataSource.apply(snapshot, animatingDifferences: true)
    }

    func updateLayoutType(_ newLayout: SearchResultLayoutType) {
        self.layout = newLayout
    }
}

extension SearchResultDataSource {

    enum Section: Hashable  {
        case main
    }

    enum SectionItem: Hashable {
        case searchResult(SearchResultCellViewModelProtocol)
        case searchInput(SearchInputItemCellViewModelProtocol)

        static func == (lhs: SectionItem, rhs: SectionItem) -> Bool {
            switch (lhs, rhs) {
            case (.searchResult(let lViewModel), .searchResult(let rViewModel)):
                return lViewModel.uniqueId == rViewModel.uniqueId

            case (.searchInput(let lViewModel), .searchInput(let rViewModel)):
                guard type(of: lViewModel) == type(of: rViewModel) else { return false }
                if let lHashtag = lViewModel as? SearchInputHashtagCellViewModel,
                   let rHashtag = rViewModel as? SearchInputHashtagCellViewModel {
                    return lHashtag.hashtag?.id == rHashtag.hashtag?.id
                    
                } else if let lActor = lViewModel as? SearchInputActorCellViewModel,
                         let rActor = rViewModel as? SearchInputActorCellViewModel {
                    return lActor.actor?.id == rActor.actor?.id
                }

                return false
            default:
                return false
            }
        }

        func hash(into hasher: inout Hasher) {
            switch self {
            case .searchResult(let viewModel):
                hasher.combine(viewModel.postURL)
                hasher.combine(viewModel.title)
                hasher.combine(viewModel.subTitle)
            case .searchInput(let viewModel):
                if let hashtagVM = viewModel as? SearchInputHashtagCellViewModel {
                    hasher.combine(hashtagVM.keyword)
                    hasher.combine(hashtagVM.hashtag?.id)
                } else if let actorVM = viewModel as? SearchInputActorCellViewModel {
                    hasher.combine(actorVM.title)
                    hasher.combine(actorVM.actor?.id)
                }
            }
        }

        var viewModel: CellViewModelProtocol {
            switch self {
            case .searchResult(let vm): return vm
            case .searchInput(let vm): return vm
            }
        }
    }
}

final class SearchTypeHandler {
    enum ResponseParser {
        case hashtag(GetSearchKeywordsResponseModel)
        case keyword(GetSearchMoviesResponseModel)
        case actor(GetSearchActorsResponseModel)
        case discover(DiscoverMoviesResponseModel)

        var canSwitchLayout: Bool {
            switch self {
            case .hashtag, .actor:
                false
            case .keyword, .discover:
                true
            }
        }
    }

    private var keywordText: String?
    private var castID: String?
    private var hashtagID: String?
    private let searchType: SearchType
    private let isFromSearchOption: Bool

    init(keywordText: String? = nil, castID: String? = nil, hashtagID: String? = nil, searchType: SearchType, isFromSearchOption: Bool) {
        self.keywordText = keywordText
        self.castID = castID
        self.hashtagID = hashtagID
        self.searchType = searchType
        self.isFromSearchOption = isFromSearchOption
    }

    func determineEndpoint(currentPage: Int) -> TMDBAPI? {
        guard isFromSearchOption == false else {
            return handleSearchEndpoint(currentPage: currentPage)
        }

        return handleDiscoverEndpoint(currentPage: currentPage)
    }

    func parseResonseModel(responseParser: ResponseParser) -> (cellViewModels: [CellViewModelProtocol],
                                                               totalPages: Int,
                                                               totalResults:Int) {
        switch responseParser {
        case .hashtag(let responseModel):
            return handleResponse(responseModel) { hashtag in
                SearchInputHashtagCellViewModel(hashtag: hashtag)
            }
        case .keyword(let responseModel):
            return handleResponse(responseModel) { movie in
                SearchResultCellViewModel(item: movie)
            }
        case .actor(let responseModel):
            return handleResponse(responseModel) { actor in
                SearchInputActorCellViewModel(actor: actor)
            }
        case .discover(let responseModel):
            return handleResponse(responseModel) { movie in
                SearchResultCellViewModel(item: movie)
            }
        }
    }

    private func handleResponse<T: PageableResponseModel>(_ response: T,
                                                          transform: (T.ResultType) -> CellViewModelProtocol) -> (cellViewModels: [CellViewModelProtocol],
                                                                                                                  totalPages: Int,
                                                                                                                  totalResults:Int) {

        return (cellViewModels: response.results.compactMap(transform),
                totalPages: response.totalPages,
                totalResults: response.totalResults)
    }

    private func handleSearchEndpoint(currentPage: Int) -> TMDBAPI? {
        guard let keywordText = self.keywordText, keywordText.isEmpty == false else {
            return nil
        }
        switch searchType {
        case .hashtag:
            let requestModel = GetSearchKeywordsRequestModel(query:keywordText, page: currentPage)
            return .getSearchKeywords(requestModel)
        case .keyword(_):
            let requestModel = GetSearchMoviesRequestModel(query:keywordText, page: currentPage)
            return .getSearchMovies(requestModel)
        case .actor(_):
            let requestModel = GetSearchActorsRequestModel(query:keywordText, page: currentPage)
            return .getSearchActors(requestModel)
        case .none:
            return nil
        }
    }

    private func handleDiscoverEndpoint(currentPage: Int) -> TMDBAPI? {
        if case .keyword(_) = searchType,
           let keywordText = self.keywordText, keywordText.isEmpty == false {
            let requestModel = GetSearchMoviesRequestModel(query:keywordText, page: currentPage)
            return .getSearchMovies(requestModel)
        }

        let requestModel = DiscoverMoviesRequestModel(sortBy: nil,
                                                      castID: self.castID,
                                                      keywordID: self.hashtagID,
                                                      primaryReleaseYear: nil,
                                                      page: currentPage)
        return .discoverMovies(requestModel)
    }
}
