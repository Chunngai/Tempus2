//
//  TextViewWithPlaceHolder.swift
//  Tempus2
//
//  Created by Sola on 2021/9/3.
//  Copyright © 2021 Sola. All rights reserved.
//

import UIKit

class TextViewWithPlaceHolder: UITextView {
    
    var placeHolder: String?
    var isShowingPlaceHolder: Bool {
        guard let placeHolder = placeHolder else {
            return false
        }
        return text == placeHolder
            && textColor == Theme.placeHolderColor
    }
    
    var content: String {
        get {
            guard let text = text else {
                return ""
            }
            if text != placeHolder {
                return text
            } else {
                return ""
            }
        }
        set {
            if newValue.isEmpty {
                text = placeHolder
                textColor = Theme.placeHolderColor
                selectMostLeft()
            } else {
                text = isShowingPlaceHolder
                    // textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
                    // will update the text.
                    // So no need to update here.
                    ? ""
                    : newValue
                textColor = Theme.textColor
            }
        }
    }
    
    // MARK: - Init
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TextViewWithPlaceHolder {
    override func becomeFirstResponder() -> Bool {
        let bool = super.becomeFirstResponder()
        
        if text == placeHolder {
            selectMostLeft()
        }
        return bool
    }
}
