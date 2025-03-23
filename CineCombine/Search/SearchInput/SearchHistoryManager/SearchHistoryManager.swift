//
//  SearchHistoryManager.swift
//  CineCombine
//
//  Created by KarenChiu on 2024/10/13.
//

import Foundation
protocol SearchHistoryManagerProtocol {
    func toCellViewModel() -> [SearchInputViewModel.SectionItem]
    func addSearchHistoryItem(_ item: SearchHistoryItem)
    func clearHistory()
}

class SearchHistoryManager: SearchHistoryManagerProtocol {
    static let shared = SearchHistoryManager()
    private let maxCount = 5

    private init() {}

    @UserDefault(key: "searchHistory", defaultValue: [])
    private var searchHistory: [SearchHistoryItem]

    var history: [SearchHistoryItem] {
        searchHistory
    }

    func addSearchHistoryItem(_ item: SearchHistoryItem) {
        var updatedHistory = searchHistory.filter { $0 != item }
        updatedHistory.insert(item, at: 0)
        searchHistory = Array(updatedHistory.prefix(maxCount))
    }

    func clearHistory() {
        searchHistory = []
    }

    func toCellViewModel() -> [SearchInputViewModel.SectionItem] {
        return searchHistory.compactMap { SearchHistoryMapper.toViewModel($0) }
    }
}
