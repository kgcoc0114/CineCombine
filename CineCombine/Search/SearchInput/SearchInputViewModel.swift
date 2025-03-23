//
//  SearchInputViewModel.swift
//  CineCombine
//
//  Created by KarenChiu on 2024/10/12.
//

import Foundation
import Combine

class SearchInputViewModel {
    typealias SectionItem = SearchLogic & SearchInputItemCellViewModelProtocol

    enum Section {
        case history([SectionItem])
        case suggestion([SectionItem])
        case option([SectionItem])

        var cellViewModels: [SectionItem] {
            switch self {
            case .history(let array): return array
            case .suggestion(let array): return array
            case .option(let array): return array
            }
        }
    }

    lazy var options: [SectionItem] = {
        return [SearchInputKeywordCellViewModel(isSearchOption: true, keyword: searchText),
                SearchInputHashtagCellViewModel(isSearchOption: true, keyword: searchText),
                SearchInputActorCellViewModel(isSearchOption: true, keyword: searchText)]
    }()

    var cancellables = Set<AnyCancellable>()
    private let historyManager: SearchHistoryManagerProtocol

    // output
    @Published var searchText: String = ""
    @Published private(set) var sections: [Section] = []
    @Published private(set) var error: SearchError?

    init(initialSearchText: String = "",
         historyManager: SearchHistoryManagerProtocol = SearchHistoryManager.shared) {
        self.historyManager = historyManager
        setupBindings()
    }

    private func setupBindings() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] text in
                self?.updateSections(for: text)
            }
            .store(in: &cancellables)
    }

    func numberOfItems(in section: Section) -> Int {
        return dataFor(section: section).count
    }

    func item(at indexPath: IndexPath) -> SearchInputItemCellViewModelProtocol? {
        guard indexPath.section < sections.count else { return nil }
        let section = sections[indexPath.section]
        let sectionData = dataFor(section: section)
        return sectionData.indices.contains(indexPath.row) ? sectionData[indexPath.row] : nil
    }

    func saveSearchHistory(with data: SearchInputItemCellViewModelProtocol?) {
        if let data = data {
            let searchHistoryItem = SearchHistoryMapper.fromViewModel(data)
            historyManager.addSearchHistoryItem(searchHistoryItem)
        } else {
            let searchHistoryItem = SearchHistoryMapper.fromViewModel(SearchInputKeywordCellViewModel(keyword: self.searchText))

            historyManager.addSearchHistoryItem(searchHistoryItem)
        }
    }

    func clearSearchHistory() {
        historyManager.clearHistory()
        updateSections()
    }

    private func dataFor(section: Section) -> [SearchInputItemCellViewModelProtocol] {
        switch section {
        case .history(let array), .suggestion(let array), .option(let array):
            return array
        }
    }

    private func updateSections(for query: String? = nil) {
        sections.removeAll()

        if let query = query,
           query.isEmpty == false {
            updateOption(for: query)
            updateSuggestion(for: query)
        } else {
            updateHistory()
        }
    }

    private func updateSection(_ newSection: Section) {
        if let index = sections.firstIndex(where: { section in
            switch (section, newSection) {
            case (.history, .history), (.suggestion, .suggestion), (.option, .option):
                return true
            default:
                return false
            }
        }) {
            sections[index] = newSection
        } else {
            sections.append(newSection)
        }
    }
}

// MARK: Update section
extension SearchInputViewModel {

    private func updateOption(for query: String) {
        for option in self.options {
            option.updateKeyword(with: query)
            option.searchResultViewModel?.updateKeywordText(with: query)
        }
        self.updateSection(.option(options))
    }

    private func updateHistory() {
        let historyItems: [SectionItem] = historyManager.toCellViewModel()

        guard historyItems.isEmpty == false else {
            self.error = .noData
            return
        }

        self.updateSection(.history(historyItems))
    }

    private func updateSuggestion(for query: String) {
        getSearchSuggestions(for: query)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case let .failure(error) = completion {
                    print("Error fetching search suggestions: \(error)")
                }
            } receiveValue: { [weak self] suggestions in
                self?.updateSection(.suggestion(suggestions))
            }
            .store(in: &cancellables)
    }

}

// MARK: API Fetch Data
extension SearchInputViewModel {
    func getSearchSuggestions(for query: String) -> AnyPublisher<[SearchInputViewModel.SectionItem], Error> {
        return Publishers.Zip(
            getSearchKeywordsForSuggestion(),
            getSearchActorsForSuggestion()
        )
        .map { $0 + $1 }
        .eraseToAnyPublisher()
    }

    private func getSearchActorsForSuggestion() -> AnyPublisher<[SectionItem], Error> {
        let requestModel = GetSearchActorsRequestModel(query: self.searchText)
        return APIService.request(TMDBAPI.getSearchActors(requestModel))
            .map { (response: GetSearchActorsResponseModel) -> [SectionItem] in
                return response
                    .results
                    .prefix(3)
                    .compactMap { SearchInputActorCellViewModel(actor: $0) } 
            }
            .eraseToAnyPublisher()
    }

    private func getSearchKeywordsForSuggestion() -> AnyPublisher<[SectionItem], Error> {
        let requestModel = GetSearchKeywordsRequestModel(query: self.searchText)
        return APIService.request(TMDBAPI.getSearchKeywords(requestModel))
            .map { (response: GetSearchKeywordsResponseModel) -> [SectionItem] in
                return response
                    .results
                    .prefix(3)
                    .compactMap { SearchInputHashtagCellViewModel(hashtag: $0) } 
            }
            .eraseToAnyPublisher()
    }
}
