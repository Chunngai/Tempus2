//
//  PickerCell.swift
//  Tempus2
//
//  Created by Sola on 2022/7/12.
//  Copyright © 2022 Sola. All rights reserved.
//

import UIKit

class PickerCell: UITableViewCell {

    internal var targetSelectionRow: Int!
    
    // Will be over-written.
    internal var dateAndTime: Date {
        get {
            return Date()
        }
        set {
            
        }
    }
    
    // MARK: - Controllers
    
    internal var delegate: EventEditViewController!
    
    // MARK: - Views
    
    // Will be over-written.
    internal var leftPicker: UIView {
        get {
            return UIView()
        }
        set {
            
        }
    }
    
    internal let timePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .time
        picker.isHidden = true
        // https://stackoverflow.com/questions/30245341/uidatepicker-15-minute-increments-swift
        picker.minuteInterval = 5
        return picker
    }()
    
    // MARK: - Init
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        timePicker.addTarget(
            self,
            action: #selector(timePickerValueChanged),
            for: .valueChanged
        )
        contentView.addSubview(timePicker)
    }
    
    func updateViews() {
        selectionStyle = .none
    }
    
    func updateLayouts() {
        timePicker.snp.makeConstraints { (make) in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
    }
    
    func updateValues(targetSelectionRow: Int, delegate: EventEditViewController, dateAndTime: Date) {
        self.targetSelectionRow = targetSelectionRow
        self.delegate = delegate
        
        timePicker.date = dateAndTime
    }
}

extension PickerCell {
    
    // MARK: - Actions
    
    @objc func timePickerValueChanged() {
        delegate.updateDateAndTime(ofCellInRow: targetSelectionRow, with: dateAndTime)
    }
}

protocol PickerDelegate {
    func updateDateAndTime(ofCellInRow row: Int, with newDateAndTime: Date)
}
