//
//  SearchInputHashtagCellViewModel.swift
//  CineCombine
//
//  Created by KarenChiu on 2024/10/12.
//

import Foundation
import UIKit

class SearchInputHashtagCellViewModel: SearchInputItemCellViewModelProtocol, SearchLogic {

    static var identifier: String = "SearchInputItemTableViewCell"

    var cellSize: CGSize = .zero

    var imageURL: String?

    var title: String? {
        if keyword.isEmpty == false && isSearchOption {
            return cellType.searchOptionTitle(keyword: keyword)
        } else if isFromHistory {
            if isSearchOption == false {
                return hashtag?.name
            } else {
                return  cellType.searchOptionTitle(keyword: hashtag?.name ?? "")
            }
        } else {
            return hashtag?.name
        }
    }

    var iconImage: UIImage {
        cellType.searchInputImage(isSearchOption: isSearchOption)
    }

    let subTitle: String? = nil

    let cellType: SearchType

    var keyword: String = ""
    let isSearchOption: Bool
    let isFromHistory: Bool
    var hashtag: Hashtag?
    private(set) var searchResultViewModel: SearchResultViewModel?

    init(hashtag: Hashtag? = nil,
         isSearchOption: Bool = false,
         keyword: String = "",
         isFromHistory: Bool = false) {
        self.cellType = .hashtag(SearchContext(id: Int.string(int: hashtag?.id), name: hashtag?.name))
        self.hashtag = hashtag
        self.isSearchOption = isSearchOption
        self.isFromHistory = isFromHistory
        self.keyword = keyword

        self.searchResultViewModel = SearchResultViewModel(searchType: cellType,
                                                           keywordText: isSearchOption ? keyword : self.hashtag?.name,
                                                           isFromSearchOption: isSearchOption)
    }

    func updateKeyword(with keyword: String) {
        self.keyword = keyword
        self.searchResultViewModel?.updateKeywordText(with: self.keyword)
    }
}

extension Int {
    static func string(int: Int?) -> String? {
        guard let int = int else {
            return nil
        }
        return String(int)
    }
}
