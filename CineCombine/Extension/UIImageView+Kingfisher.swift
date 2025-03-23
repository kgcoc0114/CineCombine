//
//  UIImageView+Kingfisher.swift
//  CineCombine
//
//  Created by KarenChiu on 2024/10/12.
//

import UIKit
import Kingfisher

extension UIImageView {
    func kfSetImage(url: URL?) {
        self.kf.setImage(with: url)
    }

    func kfSetImage(url: URL?, placeholder: UIImage?) {
        self.kf.setImage(with: url, placeholder: placeholder)
    }
}
