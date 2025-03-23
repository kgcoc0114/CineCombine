//
//  SearchType.swift
//  CineCombine
//
//  Created by KarenChiu on 2024/10/31.
//

import Foundation
import UIKit

enum SearchType: Codable {

    case hashtag(SearchContext)
    case keyword(SearchContext)
    case actor(SearchContext)
    case none

    var resultTitle: String {
        switch self {
        case .hashtag(let hashtag): return "#\(hashtag.name ?? "")"
        case .keyword(let keyword): return "\(keyword.name ?? "")"
        case .actor(let actor): return "\(actor.name ?? "")"
        case .none: return ""
        }
    }

    func searchOptionTitle(keyword: String) -> String {
        switch self {
        case .hashtag: return "符合「\(keyword)」之關鍵字"
        case .keyword: return "符合「\(keyword)」之電影"
        case .actor: return "符合「\(keyword)」之演員"
        case .none: return ""
        }
    }

    func searchInputImage(isSearchOption: Bool) -> UIImage {
        switch self {
        case .hashtag: return UIImage(systemName: isSearchOption ? "magnifyingglass" : "number")!
        case .actor: return UIImage(systemName: "person.2")!
        case .keyword: return UIImage(systemName: "character")!
        case .none: return UIImage(systemName: "character")!
        }
    }
}

extension SearchType: Equatable {
    static func == (lhs: SearchType, rhs: SearchType) -> Bool {
        switch (lhs, rhs) {
        case (.hashtag(let lContext), .hashtag(let rContext)):
            return lContext.id == rContext.id
        case (.keyword(let lContext), .keyword(let rContext)):
            return lContext.name == rContext.name
        case (.actor(let lContext), .actor(let rContext)):
            return lContext.id == rContext.id
        case (.none, .none):
            return true
        default:
            return false
        }
    }
}

struct SearchContext: Codable {
    let id: String?
    let name: String?
}
