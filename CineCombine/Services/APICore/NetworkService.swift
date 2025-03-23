//
//  NetworkService.swift
//  CineCombine
//
//  Created by KarenChiu on 2024/10/7.
//

import Foundation
import Combine

// MARK: - NetworkService Protocol
protocol NetworkServiceProtocol {
    static func request<T: Decodable>(_ endpoint: Endpoint) -> AnyPublisher<T, Error>
}

// MARK: - URLSessionNetworkService
struct NetworkService: NetworkServiceProtocol {
    static func request<T: Decodable>(_ endpoint: Endpoint) -> AnyPublisher<T, Error> {
        guard var urlComponents = URLComponents(url: endpoint.getURL(), resolvingAgainstBaseURL: false),
              let url = urlComponents.url else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.allHTTPHeaderFields = endpoint.headers
        request.timeoutInterval = 10

        switch endpoint.task {
        case .requestParameters(let parameters):
            urlComponents.queryItems = parameters.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
            request.url = urlComponents.url
        case .requestData(let data):
            request.httpBody = data
        case .requestEncodable(let encodable):
            do {
                if endpoint.method == .GET {
                    let queryItems = try encodableToQueryItems(encodable)
                    urlComponents.queryItems = (urlComponents.queryItems ?? []) + queryItems
                    request.url = urlComponents.url
                } else {
                    let encoder = JSONEncoder()
                    request.httpBody = try encoder.encode(encodable)
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                }
            } catch {
                return Fail(error: NetworkError.encodingError(error)).eraseToAnyPublisher()
            }
        default:
            break
        }

        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                print("=== kcc ===")
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.noData
                }
                Self.printJSONData(data)
                return data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { error -> Error in
                print("=== kcc error ===")

                if let apiError = error as? NetworkError {
                    return apiError
                }
                return NetworkError.decodingError(error)
            }
            .eraseToAnyPublisher()
    }

    private static func printJSONData(_ data: Data) {
        do {
            if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                let prettyPrintedData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
                if let prettyPrintedString = String(data: prettyPrintedData, encoding: .utf8) {
                    print("Received JSON data:")
                    print(prettyPrintedString)
                }
            } else if let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                let prettyPrintedData = try JSONSerialization.data(withJSONObject: jsonArray, options: .prettyPrinted)
                if let prettyPrintedString = String(data: prettyPrintedData, encoding: .utf8) {
                    print("Received JSON data (array):")
                    print(prettyPrintedString)
                }
            }
        } catch {
            print("Error parsing JSON: \(error)")
        }
    }

    private static func encodableToQueryItems<T: Encodable>(_ encodable: T) throws -> [URLQueryItem] {
        let data = try JSONEncoder().encode(encodable)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw NetworkError.encodingError(NSError(domain: "EncodableError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to convert Encodable to dictionary"]))
        }

        return dictionary.compactMap { (key, value) -> URLQueryItem? in
            guard let stringValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                return nil
            }
            return URLQueryItem(name: key, value: stringValue)
        }
    }
}
