//
//  TaskTableCellForTimeSelection.swift
//  Tempus2
//
//  Created by Sola on 2021/8/31.
//  Copyright © 2021 Sola. All rights reserved.
//

import UIKit

class DateAndTimeSelectionCell: EventCell {
    
    var row: Int!
    
    // MARK: - Controllers
    
    var delegate: EventEditViewController!
    
    // MARK: - Views
    
    let button: UIButton = {
        let button = UIButton()
        button.setTitleColor(Theme.textColor, for: .normal)
        button.titleLabel?.textAlignment = .center
        return button
    }()
    
    // MARK: - Init
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        textView.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action:  #selector(dateTapped)
        ))
        button.addTarget(
            self,
            action: #selector(timeTapped),
            for: .touchUpInside
        )
        
        updateViews()
        updateLayouts()
    }
    
    override func updateViews() {
        super.updateViews()
        
        textView.isEditable = false
        textView.isSelectable = false
        
        contentView.addSubview(button)
    }
    
    override func updateLayouts() {
        super.updateLayouts()
        
        // https://stackoverflow.com/questions/23107948/add-button-inside-a-text-view
        button.snp.makeConstraints { (make) in
            make.top.bottom.trailing.equalTo(textView)
            make.width.equalTo(100)
        }
    }
    
    func updateValues(
        icon: String, font: UIFont = Theme.bodyFont,
        delegate: EventEditViewController, tag: Int
    ) {
        super.updateValues(icon: icon, placeHolder: nil, text: nil, delegate: delegate, row: tag)
        
        self.delegate = delegate
        self.row = tag
        
        textView.textColor = Theme.textColor
        button.titleLabel?.font = font
    }
    
    func updateDateAndTime(with dateAndTime: Date, font: UIFont = Theme.bodyFont) {  // TODO: wrap here
        let dateRepr = NSMutableAttributedString(string: dateAndTime.localDateRepr)
        dateRepr.setFont(font: font)
        textView.attributedText = dateRepr
        
        button.setTitle(dateAndTime.localTimeRepr, for: .normal)
    }
}

extension DateAndTimeSelectionCell {
    @objc func dateTapped() {
        delegate.displayOrHideDatePicker(inRow: row + 1)
    }
    
    @objc func timeTapped() {
        delegate.displayOrHideTimePicker(inRow: row + 1)
    }
}

protocol DateAndTimeSelectionCellDelegate {
    func displayOrHideDatePicker(inRow row: Int)
    func displayOrHideTimePicker(inRow row: Int)
}
