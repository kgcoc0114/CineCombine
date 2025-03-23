//
//  UserDefault.swift
//  CineCombine
//
//  Created by KarenChiu on 2024/10/13.
//

import Foundation

@propertyWrapper
struct UserDefault<T: Codable> {
    let key: String
    let defaultValue: T
    let userDefaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(key: String, defaultValue: T, userDefaults: UserDefaults = .standard) {
        self.key = key
        self.defaultValue = defaultValue
        self.userDefaults = userDefaults
    }

    var wrappedValue: T {
        get {
            if let data = userDefaults.data(forKey: key) {
                return (try? decoder.decode(T.self, from: data)) ?? defaultValue
            }
            return defaultValue
        }
        set {
            if let encoded = try? encoder.encode(newValue) {
                userDefaults.set(encoded, forKey: key)
            }
        }
    }
}
