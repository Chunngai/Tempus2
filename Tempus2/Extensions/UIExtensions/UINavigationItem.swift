//
//  UIBarButtonItemExt.swift
//  Tempus2
//
//  Created by Sola on 2021/9/3.
//  Copyright © 2021 Sola. All rights reserved.
//

import Foundation
import UIKit

extension UINavigationItem {
        
    // https://stackoverflow.com/questions/28471164/how-to-set-back-button-text-in-swift
    func hideBackBarButtonItem() {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        self.backBarButtonItem = backItem
    }
}
