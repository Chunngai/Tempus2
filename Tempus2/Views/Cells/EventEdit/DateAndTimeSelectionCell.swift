//
//  DateAndTimeSelectionCell.swift
//  Tempus2
//
//  Created by Sola on 2021/8/31.
//  Copyright © 2021 Sola. All rights reserved.
//

import UIKit

class DateAndTimeSelectionCell: EventBaseCell {
    
    private var targetPickerRow: Int!
    
    internal var isDateValid: Bool = true {
        didSet {
            var color: UIColor
            if isDateValid {
                color = Theme.textColor
            } else {
                color = Theme.errorTextColor
            }
            dateButton.textColor = color
            timeButton.setTitleColor(color, for: .normal)
        }
    }
    
    // MARK: - Controllers
    
    private var delegate: EventEditViewController!
    
    // MARK: - Views
    
    private let dateButton: UITextView = {  // For left alignment consistence.
        let textView = UITextView()
        textView.isScrollEnabled = false
        textView.textColor = Theme.textColor
        textView.textAlignment = .left
        textView.font = Theme.bodyFont
        textView.isEditable = false
        textView.isSelectable = false
        textView.sizeToFit()
        return textView
    }()
    
    private let timeButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(Theme.textColor, for: .normal)
        button.contentHorizontalAlignment = .left
        button.titleLabel?.font = Theme.bodyFont
        button.sizeToFit()
        return button
    }()
    
    // MARK: - Init
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        dateButton.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(dateTapped)
        ))
        timeButton.addTarget(
            self,
            action: #selector(timeTapped),
            for: .touchUpInside
        )
        
        updateViews()
        updateLayouts()
    }
    
    override func updateViews() {
        super.updateViews()
        
        rightView.addSubview(dateButton)
        rightView.addSubview(timeButton)
    }
    
    override func updateLayouts() {
        super.updateLayouts()
        
        iconImageView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            // Aligns with the top of the text view (dateButton) container inset.
            make.top.equalToSuperview().inset(TextViewWithPlaceHolder().textContainerInset.top)
            make.height.width.equalTo(Theme.bodyFont.lineHeight * 1.2)
        }
        
        timeButton.snp.makeConstraints { (make) in
            make.top.bottom.trailing.equalToSuperview()
            make.width.equalTo(EventBaseCell.widthUnit)
        }
        
        dateButton.snp.makeConstraints { (make) in
            make.top.bottom.leading.equalToSuperview()
            make.trailing.equalTo(timeButton.snp.leading)
        }
    }
    
    func updateValues(
        iconName: String?,
        delegate: EventEditViewController, targetPickerRow: Int
    ) {
        super.updateValues(iconName: iconName)
        
        self.delegate = delegate
        self.targetPickerRow = targetPickerRow
    }
    
    func updateDateAndTimeRepr(with dateAndTime: Date) {
        dateButton.text = dateAndTime.dateRepresentation()
        timeButton.setTitle(dateAndTime.timeRepresentation(), for: .normal)
    }
}

extension DateAndTimeSelectionCell {
    
    // MARK: - Actions
    
    @objc func dateTapped() {
        delegate.toggleDatePickerVisibility(inRow: targetPickerRow)
    }
    
    @objc func timeTapped() {
        delegate.toggleTimePickerVisibility(inRow: targetPickerRow)
    }
}

protocol DateAndTimeSelectionCellDelegate {
    func toggleDatePickerVisibility(inRow pickerRow: Int)
    func toggleTimePickerVisibility(inRow pickerRow: Int)
}
