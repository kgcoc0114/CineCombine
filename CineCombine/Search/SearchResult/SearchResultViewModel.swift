//
//  SearchResultViewModel.swift
//  CineCombine
//
//  Created by KarenChiu on 2024/10/27.
//

import Foundation
import UIKit
import Combine

enum SearchError: Error {
    case noData
    case apiError

    var errorTitle: String? {
        return "NOTICE"
    }

    func getErrorMessage(isResultPage: Bool = true) -> String {
        switch self {
        case .noData:
            return isResultPage
            ? "No Result, Try Another search keyword"
            : "No Search History"
        case .apiError:
            return "Something Wrong. Try Again Later..."
        }
    }
}

final class SearchResultViewModel {
    typealias ResponseParser = SearchTypeHandler.ResponseParser

    enum FetchAction {
        case refresh
        case loadMore

        var pageUpdate: (Int) -> Int {
            switch self {
            case .refresh:
                return { _ in 1 }
            case .loadMore:
                return { $0 + 1 }
            }
        }
    }

    // MARK: - Properties
    private var cancellables = Set<AnyCancellable>()
    private var currentPage = 1
    private var totalPages: Int = 1
    private var totalResults: Int = 1
    private var dataSource: SearchResultDataSource?
    private let searchTypeHandler: SearchTypeHandler

    private var keywordText: String?
    private var searchType: SearchType
    private var isFromSearchOption: Bool = false
    private var castID: String?
    private var hashtagID: String?

    // Constant
    var shouldLoadMoreCount = 6

    // Private Subjects
    private let fetchSubject = PassthroughSubject<FetchAction, Never>()

    // Public Publisher
    var fetchPublisher: AnyPublisher<FetchAction, Never> {
        fetchSubject.eraseToAnyPublisher()
    }

    // Output
    @Published private(set) var cellViewModels: [CellViewModelProtocol] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: SearchError?
    @Published private(set) var layout: SearchResultLayoutType = .list
    @Published private(set) var canSwitchLayout: Bool = false

    var hasMore: Bool { totalPages > currentPage }
    var navigationTitle: String {
        isFromSearchOption
        ? searchType.searchOptionTitle(keyword: self.keywordText ?? "")
        : searchType.resultTitle
    }

    init(searchType: SearchType,
         cast: SearchContext? = nil,
         hashtag: SearchContext? = nil,
         keywordText: String? = nil,
         isFromSearchOption: Bool) {
        self.searchType = searchType
        self.isFromSearchOption = isFromSearchOption
        switch searchType {
        case .hashtag(let searchContext):
            hashtagID = searchContext.id
        case .actor(let searchContext):
            castID = searchContext.id
        default: break
        }
        self.keywordText = keywordText
        self.dataSource = SearchResultDataSource(layout: .list)
        self.searchTypeHandler = SearchTypeHandler(keywordText: self.keywordText,
                                                   castID: self.castID,
                                                   hashtagID: self.hashtagID,
                                                   searchType: self.searchType,
                                                   isFromSearchOption: self.isFromSearchOption)
        setupBinding()
    }
}

extension SearchResultViewModel {
    // MARK: - Public Method
    func configureDataSource(collectionView: UICollectionView) {
        dataSource?.configure(for: collectionView)
    }

    func loadMoreIfNeeded(at indexPath: IndexPath) {
        guard hasMore,
              indexPath.item > cellViewModels.count - shouldLoadMoreCount,
              isLoading == false else { return }
        loadMore()
    }

    func updateKeywordText(with keywordText: String) {
        self.keywordText = keywordText
    }

    func refresh() {
        fetchSubject.send(.refresh)
    }

    func loadMore() {
        fetchSubject.send(.loadMore)
    }

    func updateLayoutType() {
        self.layout = self.layout == .list ? .card : .list
        dataSource?.updateLayoutType(self.layout)
    }
}

// MARK: - Private Method
extension SearchResultViewModel {
    private func setupBinding() {
        fetchSubject
            .filter { [weak self] _ in
                self?.isLoading == false
            }
            .handleEvents(receiveOutput: { [weak self] fetchAction in
                guard let self = self else { return }
                self.isLoading = true
                self.currentPage = fetchAction.pageUpdate(self.currentPage)
            })
            .flatMap { [weak self] action -> AnyPublisher<ResponseParser, Error> in
                guard let self = self else {
                    return Fail(error: SearchError.apiError).eraseToAnyPublisher()

                }
                return self.fetchResults() ?? Fail(error: SearchError.apiError).eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure:
                    self?.error = .apiError
                    self?.isLoading = false
                }
            } receiveValue: { [weak self] responseParser in
                guard let self = self else { return }
                self.isLoading = false
                self.canSwitchLayout = responseParser.canSwitchLayout
                // parse response model
                let (cellViewModels, totalPages, totalResults) = self.searchTypeHandler.parseResonseModel(responseParser: responseParser)
                if cellViewModels.count == 0 {
                    self.error = .noData
                }
                print("KCC currentPage",currentPage, self.cellViewModels.count)
                if currentPage == 1 {
                    self.cellViewModels = cellViewModels
                } else {
                    self.cellViewModels.append(contentsOf: cellViewModels)
                }
                self.totalPages = totalPages
                self.totalResults = totalResults
            }
            .store(in: &cancellables)

        $cellViewModels.receive(on: DispatchQueue.main)
            .sink { [weak self] viewModels in
                guard let self = self else { return }
                self.applySnapshot(viewModels: viewModels)
            }
            .store(in: &cancellables)
    }

    private func applySnapshot(viewModels: [CellViewModelProtocol]? = nil) {
        guard let dataSource = dataSource else { return }
        dataSource.applySnapshot(viewModels: (viewModels ?? cellViewModels))
    }
}

extension SearchResultViewModel {

    private func fetchResults() -> AnyPublisher<ResponseParser, Error>? {
        print("KCC ",#function)
        guard let endpoint = searchTypeHandler.determineEndpoint(currentPage: currentPage) else { return nil }

        switch endpoint {
        case .discoverMovies:
            return APIService.request(endpoint)
                .map { (response: DiscoverMoviesResponseModel) -> ResponseParser in .discover(response) }
                .eraseToAnyPublisher()
        case .getSearchKeywords:
            return APIService.request(endpoint)
                .map { (response: GetSearchKeywordsResponseModel) -> ResponseParser in .hashtag(response) }
                .eraseToAnyPublisher()
        case .getSearchActors:
            return APIService.request(endpoint)
                .map { (response: GetSearchActorsResponseModel) -> ResponseParser in .actor(response) }
                .eraseToAnyPublisher()
        case .getSearchMovies:
            return APIService.request(endpoint)
                .map { (response: GetSearchMoviesResponseModel) -> ResponseParser in .keyword(response) }
                .eraseToAnyPublisher()
        default:
            return nil
        }
    }
}
