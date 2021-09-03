//
//  UITableViewCellExt.swift
//  Tempus2
//
//  Created by Sola on 2021/9/3.
//  Copyright © 2021 Sola. All rights reserved.
//

import Foundation
import UIKit

extension UITableViewCell {
    // https://stackoverflow.com/questions/8561774/hide-separator-line-on-one-uitableviewcell
    func removeSeparator() {
        separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
    }
}
