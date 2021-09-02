//
//  UITextViewExt.swift
//  Tempus2
//
//  Created by Sola on 2021/9/1.
//  Copyright © 2021 Sola. All rights reserved.
//

import Foundation
import UIKit

extension UITextView {
    func selectMostLeft() {
        self.selectedTextRange = self.textRange(
            from: self.beginningOfDocument,
            to: self.beginningOfDocument
        )
    }
}
