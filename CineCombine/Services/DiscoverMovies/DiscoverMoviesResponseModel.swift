//
//  DiscoverMoviesResponseModel.swift
//  CineCombine
//
//  Created by KarenChiu on 2024/10/7.
//

import Foundation

struct DiscoverMoviesResponseModel: PageableResponseModel {
    let page: Int
    let results: [Movie]
    let totalPages: Int
    let totalResults: Int

    enum CodingKeys: String, CodingKey {
        case page
        case results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

extension DiscoverMoviesResponseModel {
    struct Movie: Codable {
        let adult: Bool?
        let backdropPath: String?
        let genreIDs: [Int]
        let id: Int?
        let originalLanguage: String?
        let originalTitle: String?
        let overview: String?
        let popularity: Double?
        let posterPath: String?
        let releaseDate: String?
        let title: String?
        let video: Bool?
        let voteAverage: Double?
        let voteCount: Int?

        enum CodingKeys: String, CodingKey {
            case adult
            case backdropPath = "backdrop_path"
            case genreIDs = "genre_ids"
            case id
            case originalLanguage = "original_language"
            case originalTitle = "original_title"
            case overview
            case popularity
            case posterPath = "poster_path"
            case releaseDate = "release_date"
            case title
            case video
            case voteAverage = "vote_average"
            case voteCount = "vote_count"
        }
    }
}

struct DiscoverMoviesRequestModel: RequestPaginateModel {
    let sortBy: String?
    let castID: String?
    let keywordID: String?
    let primaryReleaseYear: String?
    let page: Int?

    enum CodingKeys: String, CodingKey {
        case sortBy = "sort_by"
        case castID = "with_cast"
        case keywordID = "with_keywords"
        case primaryReleaseYear = "primary_release_year"
        case page
    }
}
