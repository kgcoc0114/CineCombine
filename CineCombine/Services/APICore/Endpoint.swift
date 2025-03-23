//
//  Endpoint.swift
//  CineCombine
//
//  Created by KarenChiu on 2024/10/7.
//

import Foundation

typealias Parameters = [String: Any]

protocol Endpoint {
    var baseURL: URL { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var task: Task { get }
    var headers: [String: String]? { get }
    func getURL() -> URL
}

extension Endpoint {
    func getURL() -> URL {
        return self.baseURL.appendingPathComponent(self.path)
    }
}

struct CustomEndpoint: Endpoint {
    let baseURL: URL
    let path: String
    let method: HTTPMethod
    let task: Task
    let headers: [String : String]?
}
