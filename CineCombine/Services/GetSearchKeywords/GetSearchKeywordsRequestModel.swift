//
//  GetSearchKeywordsRequestModel.swift
//  CineCombine
//
//  Created by KarenChiu on 2024/10/13.
//

import Foundation

struct GetSearchKeywordsRequestModel: RequestModel {
    let query: String
    let page: Int

    init(query: String,
         page: Int = 1) {
        self.query = query
        self.page = page
    }
    enum CodingKeys: String, CodingKey {
        case query
        case page
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        try container.encode(encodedQuery, forKey: .query)
        try container.encode(page, forKey: .page)

    }
}
