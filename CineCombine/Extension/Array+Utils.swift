//
//  Array+Utils.swift
//  CineCombine
//
//  Created by KarenChiu on 2024/10/12.
//

import Foundation

extension Array {
    public subscript(safe index: Int) -> Element? {
        guard index >= 0, index < endIndex else {
            return nil
        }

        return self[index]
    }
}
