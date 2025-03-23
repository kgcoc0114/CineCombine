//
//  GetSearchMoviesResponseModel.swift
//  CineCombine
//
//  Created by KarenChiu on 2024/10/31.
//

import Foundation

struct GetSearchMoviesResponseModel: PageableResponseModel {
    let page: Int
    let results: [DiscoverMoviesResponseModel.Movie]
    let totalPages: Int
    let totalResults: Int

    enum CodingKeys: String, CodingKey {
        case page
        case results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}
