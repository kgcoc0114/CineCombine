//
//  GetSearchActorsResponseModel.swift
//  CineCombine
//
//  Created by KarenChiu on 2024/10/13.
//

import Foundation

class GetSearchActorsResponseModel: PageableResponseModel {
    let page: Int
    let results: [Actor]
    let totalPages: Int
    let totalResults: Int

    enum CodingKeys: String, CodingKey {
        case page
        case results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

struct Actor: Codable {
    let id: Int?
    let gender: Int?
    let knownForDepartment: String?
    let name: String?
    let originalName: String?
    let popularity: Double?
    let profilePath: String?
    let knownFor: [Movie]?

    enum CodingKeys: String, CodingKey {
        case id, gender, name, popularity
        case knownForDepartment = "known_for_department"
        case originalName = "original_name"
        case profilePath = "profile_path"
        case knownFor = "known_for"
    }
}

extension Actor {
    struct Movie: Codable {
        let id: Int
        let backdropPath: String?
        let title: String?
        let originalTitle: String?
        let overview: String?
        let posterPath: String?
        let mediaType: String?
        let adult: Bool?
        let originalLanguage: String?
        let genreIds: [Int]?
        let popularity: Double?
        let releaseDate: String?
        let video: Bool?
        let voteAverage: Double?
        let voteCount: Int?

        enum CodingKeys: String, CodingKey {
            case id, title, overview, adult, popularity, video
            case backdropPath = "backdrop_path"
            case originalTitle = "original_title"
            case posterPath = "poster_path"
            case mediaType = "media_type"
            case originalLanguage = "original_language"
            case genreIds = "genre_ids"
            case releaseDate = "release_date"
            case voteAverage = "vote_average"
            case voteCount = "vote_count"
        }
    }
}
