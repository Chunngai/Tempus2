//
//  DateAndTimePickerCell.swift
//  Tempus2
//
//  Created by Sola on 2021/8/31.
//  Copyright © 2021 Sola. All rights reserved.
//

import UIKit
import JTAppleCalendar

class DateAndTimePickerCell: UITableViewCell {
    
    private var targetSelectionRow: Int!
    
    var dateAndTime: Date {
        get {
            return Date.combine(
                date: datePicker.selectedDates[0],
                with: timePicker.date
            )
        }
        set {
            datePicker.selectDates([newValue])
            timePicker.date = newValue
        }
    }
    
    // MARK: - Controllers
    
    private var delegate: EventEditViewController!
    
    // MARK: - Views
    
    let timePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .time
        picker.isHidden = true
        // https://stackoverflow.com/questions/30245341/uidatepicker-15-minute-increments-swift
        picker.minuteInterval = 5
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
        
        timePicker.addTarget(
            self,
            action: #selector(timePickerValueChanged),
            for: .valueChanged
        )
        
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
        
        updateViews()
        updateLayouts()
    }
    
    func updateViews() {
        selectionStyle = .none
        
        contentView.addSubview(timePicker)
        contentView.addSubview(datePicker)
    }
    
    func updateLayouts() {
        timePicker.snp.makeConstraints { (make) in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
        
        datePicker.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(EventEditViewController.datePickerCellHeight)
        }
    }
    
    func updateValues(targetSelectionRow: Int, delegate: EventEditViewController, dateAndTime: Date) {
        self.targetSelectionRow = targetSelectionRow
        self.delegate = delegate
        
        datePicker.scrollToHeaderForDate(dateAndTime, withAnimation: false)
        datePicker.selectDates([dateAndTime])
        
        timePicker.date = dateAndTime
    }
}

extension DateAndTimePickerCell {
    
    // MARK: - Actions
    
    @objc func timePickerValueChanged() {
        delegate.updateDateAndTime(ofCellInRow: targetSelectionRow, with: dateAndTime)
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
        guard let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: DateAndTimePickerCell.cellReuseIdentifier, for: indexPath)
            as? DateCell else {
                return JTACDayCell()
        }
        self.calendar(
            datePicker,
            willDisplay: cell,
            forItemAt: date,
            cellState: cellState,
            indexPath: indexPath
        )
        return cell
    }
    
    func calendar(_ calendar: JTACMonthView, willDisplay cell: JTACDayCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        guard let cell = cell as? DateCell else {
            return
        }
        
        cell.updateValues(
            date: date,
            cellState: cellState,
            shouldHideDaysNotInCurrentMonth: true
        )
    }
    
    func calendar(_ calendar: JTACMonthView, didSelectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        guard let cell = cell as? DateCell else {
            return
        }
        
        cell.configSelection(of: cellState)
        
        delegate.updateDateAndTime(ofCellInRow: targetSelectionRow, with: dateAndTime)
    }
    
    func calendar(_ calendar: JTACMonthView, didDeselectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        guard let cell = cell as? DateCell else {
            return
        }
        cell.configSelection(of: cellState)
    }
    
    func calendar(_ calendar: JTACMonthView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        calendar.selectDates([visibleDates.monthDates[0].date])
    }
        
    func calendar(_ calendar: JTACMonthView, headerViewForDateRange range: (start: Date, end: Date), at indexPath: IndexPath) -> JTACMonthReusableView {
        guard let header = calendar.dequeueReusableJTAppleSupplementaryView(withReuseIdentifier: DateAndTimePickerCell.headerReuseIdentifier, for: indexPath)
            as? WeekdaysHeader else {
                return JTACMonthReusableView()
        }
        return header
    }
    
    func calendarSizeForMonths(_ calendar: JTACMonthView?) -> MonthSize? {
        return MonthSize(defaultSize: 50)
    }
}

extension DateAndTimePickerCell {
    static let cellReuseIdentifier = "DateCell"
    static let headerReuseIdentifier = "WeekdaysHeader"
}

protocol DateAndTimePickerDelegate {
    func updateDateAndTime(ofCellInRow row: Int, with newDateAndTime: Date)
}
