//
//  TaskTableCell.swift
//  Tempus2
//
//  Created by Sola on 2021/8/30.
//  Copyright © 2021 Sola. All rights reserved.
//

import UIKit

class EventCell: UITableViewCell {

    var placeHolder: String!
    
    var content: String {
        return textView.text == placeHolder ? "" : textView.text
    }
    
    // MARK: - Views
    
    var iconImageView = UIImageView()
    
    let label: UILabel = {
        let label = UILabel()
        return label
    }()
    
    let textView: UITextView = {
        let textView = UITextView()
        textView.isScrollEnabled = false
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

    func updateViews() {
        selectionStyle = .none
        
        contentView.addSubview(label)
        label.addSubview(iconImageView)
        
        contentView.addSubview(textView)
    }
    
    func updateLayouts() {
        label.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().inset(30)
            make.top.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().inset(10)
        }
        
        iconImageView.snp.makeConstraints { (make) in
            make.centerY.centerX.equalToSuperview()
            make.height.width.equalTo(Theme.bodyFont.lineHeight * 1.2)
        }
        
        textView.snp.makeConstraints { (make) in
            make.leading.equalTo(label.snp.trailing).offset(30)
            make.trailing.equalToSuperview()
            make.top.equalTo(label.snp.top)
            make.bottom.equalTo(label.snp.bottom)
        }
    }
    
    func updateValues(
        icon: String, placeHolder: NSAttributedString?, text: NSAttributedString?,
        delegate: UITableViewController, row: Int  // Dynamic height stuff.
    ) {
        iconImageView.image = UIImage(imageLiteralResourceName: icon)
            .setColor(color: Theme.weakTextColor)
        
        if let placeHolder = placeHolder {
            textView.attributedText = placeHolder
            textView.textColor = Theme.placeHolderColor
            self.placeHolder = placeHolder.string
        } else if let text = text {
            textView.attributedText = text
            textView.textColor = Theme.textColor
        }
        
        textView.delegate = delegate as? UITextViewDelegate
        textView.tag = row
    }
}
