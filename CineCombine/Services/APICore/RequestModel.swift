//
//  RequestModel.swift
//  CineCombine
//
//  Created by KarenChiu on 2024/10/7.
//

import Foundation

protocol RequestModel: Encodable {}
protocol RequestPaginateModel: RequestModel {
    var page: Int? { get }
}

extension Encodable {
    func toDict() -> [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else {
            return nil
        }

        guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .allowFragments),
              let dict = jsonObject as? [String: Any] else {
            return nil
        }

        return dict
    }
}
