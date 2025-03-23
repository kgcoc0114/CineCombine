//
//  GetMovieGenreListResponseModel.swift
//  CineCombine
//
//  Created by KarenChiu on 2024/10/7.
//

import Foundation

struct GetMovieGenreListResponseModel: ResponseModel {
    let genres: [Genre]
}

extension GetMovieGenreListResponseModel {
    struct Genre: Decodable {
        let id: Int?
        let name: String?
    }
}
