//
//  AppContext.swift
//  CineCombine
//
//  Created by KarenChiu on 2024/10/7.
//

import Foundation
import UIKit

enum WindowFactory {
    static func makeWindow(for scene: UIWindowScene) -> UIWindow {
        let window = UIWindow(windowScene: scene)
        let initVC = SearchInputViewController()
        let navigationController = UINavigationController(rootViewController: initVC)
        window.rootViewController = navigationController
        return window
    }
}
