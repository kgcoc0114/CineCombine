//
//  ResponseModel.swift
//  CineCombine
//
//  Created by KarenChiu on 2024/10/7.
//

import Foundation

protocol ResponseModel: Decodable {}

protocol PageableResponseModel<ResultType>: ResponseModel {
    associatedtype ResultType
    var page: Int { get }
    var results: [ResultType] { get }
    var totalPages: Int { get }
    var totalResults: Int { get }
}
