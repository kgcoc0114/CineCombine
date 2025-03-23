//
//  SearchResultCellViewModel.swift
//  CineCombine
//
//  Created by KarenChiu on 2024/10/27.
//

import Foundation

struct SearchResultCellViewModel: SearchResultCellViewModelProtocol {
    static var identifier: String = "SearchResultTableViewCell"

    var cellSize: CGSize = .zero

    static func == (lhs: SearchResultCellViewModel, rhs: SearchResultCellViewModel) -> Bool {
        lhs.item.id == rhs.item.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(item.id)
    }

    var postURL: String? {
        if let posterPath = item.posterPath { return "https://image.tmdb.org/t/p/w500/" + posterPath }
        return ""
    }

    var uniqueId: Int? { item.id }

    var title: String? { item.title }

    var subTitle: String? { item.releaseDate }

    var overview: String? { item.overview }

    let item: DiscoverMoviesResponseModel.Movie

    init(item: DiscoverMoviesResponseModel.Movie) {
        self.item = item
    }
}
