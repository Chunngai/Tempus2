//
//  TextViewWithPlaceHolder.swift
//  Tempus2
//
//  Created by Sola on 2021/9/3.
//  Copyright © 2021 Sola. All rights reserved.
//

import UIKit

class TextViewWithPlaceHolder: UITextView {
    
//    var clearButton: UIButton = {
//        let clearButton = UIButton(type: .custom)
//        clearButton.setImage(UIImage(imageLiteralResourceName: "clear"), for: .normal)
//        clearButton.setImage(UIImage(imageLiteralResourceName: "clear_pressed"), for: .highlighted)
//        return clearButton
//    }()
    
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
                selectBeginning()
            } else {
                text = isShowingPlaceHolder
                    // textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
                    // will update the text.
                    // So no need to update here.
                    ? ""
                    : newValue
                textColor = Theme.textColor
            }
            
            setClearButtonVisibility(content: newValue, isFirstResponder: self.isFirstResponder)
            
            delegate?.textViewDidChange?(self)
        }
    }
    
    // MARK: - Init
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
//        clearButton.addTarget(self, action: #selector(clearButtonTapped), for: .touchUpInside)
//        self.addSubview(clearButton)
        
        updateViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
//        clearButton.snp.makeConstraints { (make) in
//            make.leading.equalToSuperview().inset(self.frame.width - TextViewWithPlaceHolder.clearButtonDiameter * 2)
//            make.centerY.equalToSuperview()
//            make.width.height.equalTo(TextViewWithPlaceHolder.clearButtonDiameter)
//        }
    }
    
    func updateViews() {
        textContainerInset = UIEdgeInsets(
            top: textContainerInset.top,
            left: textContainerInset.left,
            bottom: textContainerInset.bottom,
            right: TextViewWithPlaceHolder.clearButtonDiameter * 2
        )
    }
}

extension TextViewWithPlaceHolder {
    override func becomeFirstResponder() -> Bool {
        let bool = super.becomeFirstResponder()
        
        if text == placeHolder {
            selectBeginning()
        }
        
        setClearButtonVisibility(content: content, isFirstResponder: bool)
        
        return bool
    }
    
    override func resignFirstResponder() -> Bool {
        let bool = super.resignFirstResponder()
        
        setClearButtonVisibility(content: content, isFirstResponder: !bool)
        
        return bool
    }
}

extension TextViewWithPlaceHolder {
    
    // MARK: - Actions
    
    @objc func clearButtonTapped() {
        content = ""
    }
}

extension TextViewWithPlaceHolder {
    
    private func setClearButtonVisibility(content: String, isFirstResponder: Bool) {
//        if isFirstResponder && !content.isEmpty {
//            clearButton.isHidden = false
//        } else {
//            clearButton.isHidden = true
//        }
    }
    
}

extension TextViewWithPlaceHolder {
    
    static let clearButtonDiameter: CGFloat = 15
    
}
