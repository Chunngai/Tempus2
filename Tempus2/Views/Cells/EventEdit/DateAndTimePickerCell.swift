//
//  TimePickerTableViewCell.swift
//  Tempus2
//
//  Created by Sola on 2021/8/31.
//  Copyright © 2021 Sola. All rights reserved.
//

import UIKit
import JTAppleCalendar

class DateAndTimePickerCell: UITableViewCell {
    
    var targetRow: Int!
    
    var dateAndTime: Date {
        get {
            return Date.combine(date: datePicker.selectedDates[0], with: timePicker.date)
        }
        set {
            datePicker.selectDates([newValue])
            timePicker.date = newValue
        }
    }
    
    // MARK: - Controllers
    
    var delegate: EventEditViewController!
    
    // MARK: - Views
    
    let timePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .time
        picker.isHidden = true
        return picker
    }()
    
    // https://jisng.github.io/2020/01/jtapplecalendar-programmatically/
    let datePicker: JTACMonthView = {
        let picker = JTACMonthView()
        picker.backgroundColor = .white
        picker.scrollDirection = .horizontal
        picker.scrollingMode = .stopAtEachCalendarFrame
        picker.showsVerticalScrollIndicator = false
        picker.isHidden = true
        return picker
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
        
        contentView.addSubview(timePicker)
        timePicker.addTarget(
            self,
            action: #selector(timePickerValueChanged),
            for: .valueChanged
        )
        
        contentView.addSubview(datePicker)
        datePicker.calendarDataSource = self
        datePicker.calendarDelegate = self
        datePicker.register(
            DateCell.self,
            forCellWithReuseIdentifier: DateAndTimePickerCell.cellReuseIdentifier
        )
        datePicker.register(
            WeekdaysHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: DateAndTimePickerCell.headerReuseIdentifier
        )
    }
    
    func updateLayouts() {
        timePicker.snp.makeConstraints { (make) in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
        
        datePicker.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(EventEditViewController.largeCellHeight)
        }
    }
    
    func updateValues(targetRow: Int, delegate: EventEditViewController, date: Date, time: Date) {
        self.targetRow = targetRow
        self.delegate = delegate
        
        //        datePicker.scrollToDate(date, animateScroll: false)
        datePicker.scrollToHeaderForDate(date, withAnimation: false)
        datePicker.selectDates([date])
        timePicker.date = time
    }
}

extension DateAndTimePickerCell {
    @objc func timePickerValueChanged() {
        delegate.updateDateAndTime(ofCellInRow: targetRow, with: dateAndTime)
    }
}

extension DateAndTimePickerCell: JTACMonthViewDataSource {
    func configureCalendar(_ calendar: JTACMonthView) -> ConfigurationParameters {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MM dd"
        let startDate = formatter.date(from: "2021 01 01")!
        let endDate = formatter.date(from: "2121 01 01")!
        return ConfigurationParameters(startDate: startDate, endDate: endDate, numberOfRows: 6)
    }
}

extension DateAndTimePickerCell: JTACMonthViewDelegate {
    func calendar(_ calendar: JTACMonthView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTACDayCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: DateAndTimePickerCell.cellReuseIdentifier, for: indexPath)
            as! DateCell
        self.calendar(datePicker, willDisplay: cell, forItemAt: date, cellState: cellState, indexPath: indexPath)
        return cell
    }
    
    func calendar(_ calendar: JTACMonthView, willDisplay cell: JTACDayCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        let cell = cell as! DateCell
        
        let text = cellState.dateBelongsTo == .thisMonth ? cellState.text : ""
        let bgColor = (Calendar.current.isDateInToday(date) && cellState.dateBelongsTo == .thisMonth) ? DateCell.bgColorOfToday : DateCell.commonBgColor
        cell.updateValues(
            text: text,
            backgroundColor: bgColor
        )
    }
    
    func calendar(_ calendar: JTACMonthView, didSelectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        let cell = cell as! DateCell
        configSelection(for: cell, of: cellState)
        
        delegate.updateDateAndTime(ofCellInRow: targetRow, with: dateAndTime)
    }
    
    func calendar(_ calendar: JTACMonthView, didDeselectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        guard let cell = cell as? DateCell else {
            return
        }
        configSelection(for: cell, of: cellState)
    }
    
    func calendar(_ calendar: JTACMonthView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        calendar.selectDates([visibleDates.monthDates[0].date])
    }
        
    func calendar(_ calendar: JTACMonthView, headerViewForDateRange range: (start: Date, end: Date), at indexPath: IndexPath) -> JTACMonthReusableView {
        let header = calendar.dequeueReusableJTAppleSupplementaryView(withReuseIdentifier: DateAndTimePickerCell.headerReuseIdentifier, for: indexPath)
            as! WeekdaysHeader
        return header
    }
    
    func calendarSizeForMonths(_ calendar: JTACMonthView?) -> MonthSize? {
        return MonthSize(defaultSize: 50)
    }
}

extension DateAndTimePickerCell {
    func configSelection(for cell: DateCell, of state: CellState) {
        if state.isSelected {
            if !Calendar.current.isDateInToday(state.date) {
                cell.dateLabel.backgroundColor = DateCell.bgColorOfSelection
            }
        } else {
            if !Calendar.current.isDateInToday(state.date) {
                cell.dateLabel.backgroundColor = DateCell.commonBgColor
            }
        }
        
    }
}

extension DateAndTimePickerCell {
    static let cellReuseIdentifier = "DateCell"
    static let headerReuseIdentifier = "WeekdaysHeader"
}

protocol DateAndTimePickerDelegate {
    func updateDateAndTime(ofCellInRow row: Int, with newDateAndTime: Date)
}
