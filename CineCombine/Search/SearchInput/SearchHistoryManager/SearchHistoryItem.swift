//
//  SearchHistoryItem.swift
//  CineCombine
//
//  Created by KarenChiu on 2024/12/9.
//

import Foundation

struct SearchHistoryItem: Codable, Equatable {
    let type: SearchType
    let isSearchOption: Bool

    // Hashtag 特有屬性
    let id: Int?
    let name: String?

    // Actor 特有屬性
    let profilePath: String?
    let knownForDepartment: String?

    static func == (lhs: SearchHistoryItem, rhs: SearchHistoryItem) -> Bool {
        guard lhs.type == rhs.type else { return false }
        switch rhs.type {
        case .keyword:
            return lhs.name == rhs.name
        default:
            return lhs.id == rhs.id && lhs.type == rhs.type
        }
    }
    
    init(type: SearchType,
         isSearchOption: Bool,
         id: Int?,
         name: String?,
         profilePath: String?,
         knownForDepartment: String?) {
        self.type = type
        self.isSearchOption = isSearchOption
        self.id = id
        self.name = name
        self.profilePath = profilePath
        self.knownForDepartment = knownForDepartment
    }
}
