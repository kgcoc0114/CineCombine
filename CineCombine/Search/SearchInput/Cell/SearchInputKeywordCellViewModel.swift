//
//  SearchInputKeywordCellViewModel.swift
//  CineCombine
//
//  Created by KarenChiu on 2024/10/27.
//

import Foundation
import UIKit

class SearchInputKeywordCellViewModel: SearchInputItemCellViewModelProtocol, SearchLogic {
    func updateKeyword(with keyword: String) {
        self.keyword = keyword
    }
    
    var iconImage: UIImage {
        cellType.searchInputImage(isSearchOption: isSearchOption)
    }

    var title: String? {
        isSearchOption || isFromHistory ? cellType.searchOptionTitle(keyword: keyword) : keyword
    }

    var subTitle: String?

    var imageURL: String?

    static var identifier: String = "SearchInputItemTableViewCell"

    var cellSize: CGSize = .zero

    var isSearchOption: Bool = false
    var isFromHistory: Bool = false
    var keyword: String = "" {
        didSet {
            updateSearchResultViewModel()
        }
    }

    let cellType: SearchType
    var searchResultViewModel: SearchResultViewModel?

    init(isSearchOption: Bool = false, keyword: String, isFromHistory: Bool = false) {
        self.cellType = .keyword(SearchContext(id: nil, name: keyword))
        self.isSearchOption = isSearchOption
        self.isFromHistory = isFromHistory
        self.keyword = keyword
        updateSearchResultViewModel()
    }

    private func updateSearchResultViewModel() {
        if keyword.isEmpty {
            searchResultViewModel = nil
        } else {
            guard let searchResultViewModel = searchResultViewModel
            else {
                searchResultViewModel = SearchResultViewModel(searchType: self.cellType,
                                                              keywordText: self.keyword,
                                                              isFromSearchOption: isSearchOption)
                return
            }
            searchResultViewModel.updateKeywordText(with: self.keyword)
        }
    }
}
