//
//  GetSearchKeywordsResponseModel.swift
//  CineCombine
//
//  Created by KarenChiu on 2024/10/13.
//

import Foundation

class GetSearchKeywordsResponseModel: PageableResponseModel {
    let page: Int
    let results: [Hashtag]
    let totalPages: Int
    let totalResults: Int

    enum CodingKeys: String, CodingKey {
        case page
        case results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

struct Hashtag: Codable {
    let id: Int?
    let name: String?
}
