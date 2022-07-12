//
//  DateAndTimePickerCell.swift
//  Tempus2
//
//  Created by Sola on 2021/8/31.
//  Copyright © 2021 Sola. All rights reserved.
//

import UIKit
import JTAppleCalendar

class WeekdayAndTimePickerCell: PickerCell, UIPickerViewDataSource, UIPickerViewDelegate {
    
    override var dateAndTime: Date {
        get {
            for i in 0...6 {
                let updatedDate = Date(timeInterval: Double(i) * TimeInterval.Day, since: timePicker.date)
                
                if weekdayPicker.selectedRow(inComponent: 0) == obtainPickerRowIndex(from: updatedDate) {
                    return updatedDate
                }
            }
            
            return Date()
        }
        set {
            weekdayPicker.selectRow(obtainPickerRowIndex(from: newValue), inComponent: 0, animated: false)
            timePicker.date = newValue
        }
    }
    
    // MARK: - Views
    
    // https://stackoverflow.com/questions/24094158
    override var leftPicker: UIView {
        get {
            return weekdayPicker
        }
        set {
            print("Setting weekday picker")
        }
    }
    
    let weekdayPicker: UIPickerView = {
        let picker = UIPickerView()
        picker.backgroundColor = .white
        picker.isHidden = true
        return picker
    }()
    
    // MARK: - Init
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        weekdayPicker.dataSource = self
        weekdayPicker.delegate = self
        contentView.addSubview(weekdayPicker)
        
        updateViews()
        updateLayouts()
    }
    
    override func updateLayouts() {
        super.updateLayouts()
        
        weekdayPicker.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(EventEditViewController.datePickerCellHeight)
        }
    }
    
    override func updateValues(targetSelectionRow: Int, delegate: EventEditViewController, dateAndTime: Date) {
        super.updateValues(targetSelectionRow: targetSelectionRow, delegate: delegate, dateAndTime: dateAndTime)

        weekdayPicker.selectRow(obtainPickerRowIndex(from: dateAndTime), inComponent: 0, animated: false)
    }
}

extension WeekdayAndTimePickerCell {
    
    // MARK: - Utils
    
    func obtainPickerRowIndex(from date: Date) -> Int {
        return Calendar.current.weekdaySymbolIndex(of: date)
    }
    
}

extension WeekdayAndTimePickerCell {
    
    // MARK: - UIPickerView data source
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 7
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Calendar.current.weekdaySymbols[row]
    }
}

extension WeekdayAndTimePickerCell {
    
    // MARK: - UIPickerView delegate
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        delegate.updateDateAndTime(ofCellInRow: targetSelectionRow, with: dateAndTime)
    }
}
