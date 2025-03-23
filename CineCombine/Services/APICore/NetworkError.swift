//
//  NetworkError.swift
//  CineCombine
//
//  Created by KarenChiu on 2024/10/7.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError(Error)
    case encodingError(Error)
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL."
        case .decodingError(let error):
            return "Failed to decode the response: \(error.localizedDescription)"
        case .encodingError(let error):
            return "Failed to encode the response: \(error.localizedDescription)"
        case .noData:
            return "No data."
        case .unknown(let error):
            return "An unknown error occurred: \(error.localizedDescription)"
        }
    }
}
