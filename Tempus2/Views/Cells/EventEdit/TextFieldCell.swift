//
//  TextFieldCell.swift
//  Tempus2
//
//  Created by Ho on 4/24/25.
//  Copyright © 2025 Sola. All rights reserved.
//

import UIKit

class TextFieldCell: EventBaseCell {
    
    // MARK: - Views
    
    internal let textField: UITextField = {
        let textField = UITextField()
        return textField
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
                
        rightView.addSubview(textField)
    }
    
    override func updateLayouts() {
        super.updateLayouts()
        
        textField.snp.makeConstraints { (make) in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    func updateValues(
        iconName: String,
        placeHolder: String, text: String, font: UIFont = Theme.bodyFont
    ) {
        super.updateValues(iconName: iconName)
        
        textField.attributedPlaceholder = NSAttributedString(
            string: placeHolder,
            attributes: [.foregroundColor: Theme.placeHolderColor]
        )
        textField.text = text
        textField.font = font
    }
}
