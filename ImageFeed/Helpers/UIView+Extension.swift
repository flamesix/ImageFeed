//
//  UIView+Extension.swift
//  ImageFeed
//
//  Created by Юрий Гриневич on 15.06.2024.
//

import UIKit

extension UIView {
    func addSubviews(_ views: UIView...) {
        for view in views {
            addSubview(view)
        }
    }
}
