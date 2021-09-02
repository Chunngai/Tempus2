//
//  EventDisplayCell.swift
//  Tempus2
//
//  Created by Sola on 2021/9/1.
//  Copyright © 2021 Sola. All rights reserved.
//

import UIKit

class EventDisplayCell: EventCell {

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
        
        selectionStyle = .none
        
        textView.isEditable = false
    }
    
    override func updateLayouts() {
        super.updateLayouts()
    }
    
    func updateValues(
        icon: String, attributedText: NSAttributedString, font: UIFont = Theme.bodyFont,
        delegate: UITableViewController, row: Int  // Dynamic height stuff.
    ) {
        super.updateValues(icon: icon, placeHolder: nil, text: attributedText, delegate: delegate, row: row)
        
        textView.textColor = Theme.textColor
    }
}
