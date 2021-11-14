//
//  UINavigationBarExt.swift
//  Tempus2
//
//  Created by Sola on 2021/9/3.
//  Copyright © 2021 Sola. All rights reserved.
//

import Foundation
import UIKit

extension UINavigationBar {
    // https://stackoverflow.com/questions/26390072/how-to-remove-border-of-the-navigationbar-in-swift
    func hideBarSeparator() {
        setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        shadowImage = UIImage()
    }
    
    // https://stackoverflow.com/questions/26390072/how-to-remove-border-of-the-navigationbar-in-swift
    func showBarSeparator() {
        setBackgroundImage(nil, for: UIBarMetrics.default)
        shadowImage = nil
    }
}
