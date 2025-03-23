//
//  SearchHistoryMapper.swift
//  CineCombine
//
//  Created by KarenChiu on 2024/12/9.
//

import Foundation

struct SearchHistoryMapper {
    static func toViewModel(_ item: SearchHistoryItem) -> SearchInputViewModel.SectionItem? {
        switch item.type {
        case .hashtag:
            return Self.createHashtagViewModel(item)
        case .actor:
            return Self.createActorViewModel(item)
        case .keyword:
            return Self.createKeywordViewModel(item)
        default:
            return nil
        }
    }

    static func fromViewModel(_ viewModel: SearchInputItemCellViewModelProtocol) -> SearchHistoryItem {
        switch viewModel {
        case let actorVM as SearchInputActorCellViewModel:
            return SearchHistoryItem(type: actorVM.cellType,
                                     isSearchOption: actorVM.isSearchOption,
                                     id: actorVM.actor?.id,
                                     name: actorVM.actor?.name ?? actorVM.keyword,
                                     profilePath: actorVM.actor?.profilePath,
                                     knownForDepartment: actorVM.actor?.knownForDepartment)
        case let hashtagVM as SearchInputHashtagCellViewModel:
            return SearchHistoryItem(type: hashtagVM.cellType,
                                     isSearchOption: hashtagVM.isSearchOption,
                                     id: hashtagVM.hashtag?.id,
                                     name: hashtagVM.hashtag?.name ?? hashtagVM.keyword,
                                     profilePath: nil,
                                     knownForDepartment: nil)
        case let keywordVM as SearchInputKeywordCellViewModel:
            return SearchHistoryItem(type: keywordVM.cellType,
                                     isSearchOption: keywordVM.isSearchOption,
                                     id: nil,
                                     name: keywordVM.keyword,
                                     profilePath: nil,
                                     knownForDepartment: nil)
        default:
            return SearchHistoryItem(type: .none,
                                     isSearchOption: false,
                                     id: nil,
                                     name: nil,
                                     profilePath: nil,
                                     knownForDepartment: nil)
        }
    }
}

extension SearchHistoryMapper {
    // MARK: - Private ViewModel Creators
    private static func createHashtagViewModel(_ item: SearchHistoryItem) -> SearchInputHashtagCellViewModel {
        let hashtag = Hashtag(id: item.id, name: item.name)
        return SearchInputHashtagCellViewModel(hashtag: hashtag,
                                               isSearchOption: item.isSearchOption,
                                               isFromHistory: true)
    }

    private static func createActorViewModel(_ item: SearchHistoryItem) -> SearchInputActorCellViewModel {
        let actor: Actor?
        let keyword: String

        if item.id != nil {
            actor = Actor(id: item.id,
                          gender: nil,
                          knownForDepartment: item.knownForDepartment,
                          name: item.name,
                          originalName: nil,
                          popularity: nil,
                          profilePath: item.profilePath,
                          knownFor: nil)
            keyword = ""
        } else {
            actor = nil
            keyword = item.name ?? ""
        }

        return SearchInputActorCellViewModel(actor: actor,
                                             isSearchOption: item.isSearchOption,
                                             keyword: keyword,
                                             isFromHistory: true)
    }

    private static func createKeywordViewModel(_ item: SearchHistoryItem) -> SearchInputKeywordCellViewModel {
        return SearchInputKeywordCellViewModel(isSearchOption: false,
                                               keyword: item.name ?? "",
                                               isFromHistory: true)
    }
}
