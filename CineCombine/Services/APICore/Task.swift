//
//  Task.swift
//  CineCombine
//
//  Created by KarenChiu on 2024/10/7.
//

import Foundation

enum Task {
    case requestPlain
    case requestEncodable(Encodable)
    case requestParameters(Parameters)
    case requestData(Data)
}
