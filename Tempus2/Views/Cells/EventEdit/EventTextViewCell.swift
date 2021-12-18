//
//  EventTextViewCell.swift
//  Tempus2
//
//  Created by Sola on 2021/8/30.
//  Copyright © 2021 Sola. All rights reserved.
//

import UIKit

class EventTextViewCell: EventBaseCell {
    
    // MARK: - Views
    
    internal let textView: TextViewWithPlaceHolder = {
        let textView = TextViewWithPlaceHolder()
        textView.isScrollEnabled = false
        textView.textColor = Theme.textColor
        return textView
    }()
    
    // MARK: - Init
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        updateViews()
        updateLayouts()
    }
    
    override func updateViews() {
        super.updateViews()
                
        rightView.addSubview(textView)
    }
    
    override func updateLayouts() {
        super.updateLayouts()
        
        iconImageView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            // Aligns with the top of the text view container inset.
            make.top.equalToSuperview().inset(TextViewWithPlaceHolder().textContainerInset.top)
            make.height.width.equalTo(Theme.bodyFont.lineHeight * 1.2)
        }
        
        textView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    func updateValues(
        iconName: String,
        placeHolder: String, text: String, font: UIFont = Theme.bodyFont,
        delegate: UITableViewController
    ) {
        super.updateValues(iconName: iconName)
        
        textView.placeHolder = placeHolder
        textView.content = text
        textView.font = font
        textView.delegate = delegate as? UITextViewDelegate
    }
}
