//
//  GetSearchActorsRequestModel.swift
//  CineCombine
//
//  Created by KarenChiu on 2024/10/13.
//

import Foundation

struct GetSearchActorsRequestModel: RequestModel {
    let query: String
    let includeAdult: Bool
    let language: String
    let page: Int

    enum CodingKeys: String, CodingKey {
        case query
        case includeAdult = "include_adult"
        case language
        case page
    }

    init(query: String,
         includeAdult: Bool = false,
         language: String = "en-US",
         page: Int = 1) {
        self.query = query
        self.includeAdult = includeAdult
        self.language = language
        self.page = page
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        try container.encode(encodedQuery, forKey: .query)
        try container.encode(language, forKey: .language)
        try container.encode(page, forKey: .page)

        // 將 Bool 編碼成 "true"/"false" 字串
        let includeAdultString = includeAdult ? "true" : "false"
        try container.encode(includeAdultString, forKey: .includeAdult)
    }
}
