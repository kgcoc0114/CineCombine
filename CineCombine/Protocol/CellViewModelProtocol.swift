//
//  CellViewModelProtocol.swift
//  CineCombine
//
//  Created by KarenChiu on 2024/10/12.
//

import UIKit

protocol CellViewModelProtocol {
    static var identifier: String { get }
    var cellSize: CGSize { get }
    // 以下 optional
    static func usingNib() -> UINib?
    static func usingClass() -> AnyClass?
}

extension CellViewModelProtocol {
    static func usingNib() -> UINib? {
        return nil
    }

    static func usingClass() -> AnyClass? {
        return nil
    }
}
