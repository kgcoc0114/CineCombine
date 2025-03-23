//
//  APIService.swift
//  CineCombine
//
//  Created by KarenChiu on 2024/10/7.
//

import Foundation
import Combine

protocol APIServiceProtocol {
    static func request<T: Decodable>(_ endpoint: Endpoint) -> AnyPublisher<T, Error>
}

struct APIService: APIServiceProtocol {
    static func request<T: Decodable>(_ endpoint: Endpoint) -> AnyPublisher<T, Error> {
        return NetworkService.request(endpoint)
    }
}
