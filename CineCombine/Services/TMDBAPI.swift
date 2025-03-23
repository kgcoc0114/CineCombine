//
//  TMDBAPI.swift
//  CineCombine
//
//  Created by KarenChiu on 2024/10/7.
//

import Foundation

enum TMDBAPI: Endpoint {
    case discoverMovies(RequestModel)
    case getMovieGenreList
    case getSearchKeywords(RequestModel)
    case getSearchActors(RequestModel)
    case getSearchMovies(RequestModel)
}

extension TMDBAPI {
    var baseURL: URL {
        return URL(string: "https://api.themoviedb.org/3")!
    }

    var path: String {
        switch self {
        case .discoverMovies:
            return "discover/movie"
        case .getMovieGenreList:
            return "genre/movie/list"
        case .getSearchKeywords:
            return "search/keyword"
        case .getSearchActors:
            return "search/person"
        case .getSearchMovies:
            return "search/movie"
        }
    }

    var method: HTTPMethod {
        return .GET
    }

    var task: Task {
        switch self {
        case .discoverMovies(let requestModel):
            return .requestEncodable(requestModel)
        case .getMovieGenreList:
            return .requestPlain
        case .getSearchKeywords(let requestModel):
            return .requestEncodable(requestModel)
        case .getSearchActors(let requestModel):
            return .requestEncodable(requestModel)
        case .getSearchMovies(let requestModel):
            return .requestEncodable(requestModel)
        }
    }

    var headers: [String : String]? {
        return ["accept": "application/json",
                "Authorization": "Bearer \(TOKEN)"]
    }

    var sampleData: Data {
        return Data() // 用於測試時的假資料
    }
}
