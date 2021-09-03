//
//  NSAttributedStringExt.swift
//  Tempus2
//
//  Created by Sola on 2021/9/1.
//  Copyright © 2021 Sola. All rights reserved.
//

import Foundation
import UIKit

extension NSMutableAttributedString {
    func set(attributes: [NSAttributedString.Key: Any], for text: String? = nil) {
        let range: NSRange?
        if let text = text {
            range = self.mutableString.range(of: text)
        } else {
            range = NSMakeRange(0, self.length)
        }
        if range!.location != NSNotFound {
            addAttributes(attributes, range: range!)
        }
    }
    
    func set(font: UIFont, for text: String? = nil) {
        set(
            attributes: [.font : font],
            for: text
        )
    }
    
    // https://stackoverflow.com/questions/33818529/swift-strikethroughstyle-for-label-middle-delete-line-for-label
    func setDeleteLine(for text: String? = nil) {
        set(
            attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue],
            for: text
        )
    }
}
