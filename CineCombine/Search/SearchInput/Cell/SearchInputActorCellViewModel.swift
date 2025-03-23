//
//  SearchInputActorCellViewModel.swift
//  CineCombine
//
//  Created by KarenChiu on 2024/10/12.
//

import Foundation
import UIKit

// https://image.tmdb.org/t/p/w500/xN6SBJVG8jqqKQrgxthn3J2m49S.jpg
class SearchInputActorCellViewModel: SearchInputItemCellViewModelProtocol, SearchLogic {
    static var identifier: String = "SearchInputItemTableViewCell"

    var cellSize: CGSize = .zero

    var imageURL: String? {
        guard let profilePath = actor?.profilePath else { return nil }

        return "https://image.tmdb.org/t/p/w500\(profilePath)"
    }

    var title: String? {
        keyword.isEmpty == false && isSearchOption
        ? cellType.searchOptionTitle(keyword: keyword)
        : actor?.name
    }

    var iconImage: UIImage {
        cellType.searchInputImage(isSearchOption: isSearchOption)
    }

    var subTitle: String? {
        isSearchOption == false
        ? actor?.knownForDepartment
        : nil
    }

    let cellType: SearchType

    private(set) var keyword: String = ""
    let isSearchOption: Bool
    let isFromHistory: Bool
    var actor: Actor?

    private(set) var searchResultViewModel: SearchResultViewModel?

    init(actor: Actor? = nil, isSearchOption: Bool = false, keyword: String = "", isFromHistory: Bool = false) {
        self.cellType = .actor(SearchContext(id: Int.string(int: actor?.id), name: actor?.name))
        self.actor = actor
        self.isSearchOption = isSearchOption
        self.isFromHistory = isFromHistory
        self.keyword = keyword
        self.searchResultViewModel = SearchResultViewModel(searchType: self.cellType,
                                                           keywordText: self.actor?.name ?? self.keyword,
                                                           isFromSearchOption: isSearchOption)
    }

    func updateKeyword(with keyword: String) {
        self.keyword = keyword
        self.searchResultViewModel?.updateKeywordText(with: self.keyword)
    }
}
