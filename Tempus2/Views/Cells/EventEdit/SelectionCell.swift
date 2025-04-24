//
//  DateAndTimeSelectionCell.swift
//  Tempus2
//
//  Created by Sola on 2021/8/31.
//  Copyright © 2021 Sola. All rights reserved.
//

import UIKit

class SelectionCell: EventBaseCell {
    
    private var targetPickerRow: Int!
    
    internal var isDateValid: Bool = true {
        didSet {
            var color: UIColor
            if isDateValid {
                color = Theme.textColor
            } else {
                color = Theme.errorTextColor
            }
            dateButton.setTitleColor(color, for: .normal)
            timeButton.setTitleColor(color, for: .normal)
        }
    }
    
    private var shouldHideDate: Bool!
    
    // MARK: - Controllers
    
    private var delegate: EventEditViewController!
    
    // MARK: - Views
    
    private let dateButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(Theme.textColor, for: .normal)
        button.contentHorizontalAlignment = .left
        button.titleLabel?.font = Theme.bodyFont
        button.sizeToFit()
        return button
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
        
        dateButton.addTarget(
            self,
            action: #selector(dateTapped),
            for: .touchUpInside
        )
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

        rightView.snp.remakeConstraints { (make) in
            make.leading.equalTo(iconBackView.snp.trailing)
            make.trailing.equalToSuperview()
            make.top.equalToSuperview().inset(0)
            make.bottom.equalToSuperview().inset(Theme.bodyFont.pointSize)
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
    
    func updateDateAndTimeRepr(with dateAndTime: Date, displayWeek: Bool = false) {
        if !displayWeek {
            dateButton.setTitle(dateAndTime.dateRepresentation(), for: .normal)
        } else {
            dateButton.setTitle(Calendar.current.weekdaySymbol(of: dateAndTime), for: .normal)
        }
        timeButton.setTitle(dateAndTime.timeRepresentation(), for: .normal)
    }
}

extension SelectionCell {
    
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
