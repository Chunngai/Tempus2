//
//  CalendarViewController.swift
//  Tempus2
//
//  Created by Sola on 2021/9/5.
//  Copyright © 2021 Sola. All rights reserved.
//

import UIKit
import JTAppleCalendar

class CalendarViewController: UIViewController {
    
    private var currentMonth: Date! {
        didSet {
            navigationItem.title = currentMonth.monthRepresentation()
        }
    }
    
    // MARK: - Controllers
    
    private var delegate: HomeViewController!
    
    // MARK: - Views
    
    private let calendar: JTACMonthView = {
        let calendar = JTACMonthView()
        calendar.backgroundColor = .white
        calendar.scrollDirection = .horizontal
        calendar.scrollingMode = .stopAtEachCalendarFrame
        calendar.showsVerticalScrollIndicator = false
        calendar.minimumLineSpacing = 0
        calendar.minimumInteritemSpacing = 0
        calendar.showsHorizontalScrollIndicator = false
        return calendar
    }()
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(imageLiteralResourceName: "now"),
            style: .plain,
            target: self,
            action: #selector(thisMonthButtonTapped)
        )
        
        calendar.calendarDataSource = self
        calendar.calendarDelegate = self
        calendar.register(
            CalendarCell.self,
            forCellWithReuseIdentifier: CalendarViewController.cellReuseIdentifier
        )
        calendar.register(
            WeekdaysHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: CalendarViewController.headerReuseIdentifier
        )
        
        updateViews()
        updateLayouts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.hideBarSeparator()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.showBarSeparator()
    }
    
    func updateViews() {
        view.backgroundColor = .white
            
        view.addSubview(calendar)
    }
    
    func updateLayouts() {
        calendar.snp.makeConstraints { (make) in
            make.top.bottom.leading.trailing.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    func updateValues(date: Date, delegate: HomeViewController) {
        currentMonth = date
        calendar.scrollToHeaderForDate(currentMonth, withAnimation: false)
        
        self.delegate = delegate
    }
}

extension CalendarViewController {
    
    // MARK: - Actions
    
    @objc func thisMonthButtonTapped() {
        currentMonth = Date()
        calendar.scrollToHeaderForDate(currentMonth, withAnimation: true)
    }
    
}

extension CalendarViewController: JTACMonthViewDataSource {
    
    // MARK: - JTACMonthView Data Source
    
    func configureCalendar(_ calendar: JTACMonthView) -> ConfigurationParameters {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MM dd"
        let startDate = formatter.date(from: "2021 01 01")!
        let endDate = formatter.date(from: "2121 01 01")!
        return ConfigurationParameters(startDate: startDate, endDate: endDate, numberOfRows: 6)
    }
}

extension CalendarViewController: JTACMonthViewDelegate {
    
    // MARK: - JTACMonthView Delegate
    
    func calendar(_ calendar: JTACMonthView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTACDayCell {
        guard let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: CalendarViewController.cellReuseIdentifier, for: indexPath)
            as? CalendarCell else {
                return JTACDayCell()
        }
        self.calendar(
            calendar,
            willDisplay: cell,
            forItemAt: date,
            cellState: cellState,
            indexPath: indexPath
        )
        return cell
    }
    
    func calendar(_ calendar: JTACMonthView, willDisplay cell: JTACDayCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        guard let cell = cell as? CalendarCell else {
            return
        }
        
        var hasTasks = false
        if delegate.containsTasksOf(date: date) {
            hasTasks = true
        }
        cell.updateValues(
            date: date,
            cellState: cellState,
            hasTasks: hasTasks,
            shouldDrawBottomLine: indexPath.row >= 35 && indexPath.row <= 41
        )
    }
    
    func calendar(_ calendar: JTACMonthView, didSelectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        delegate.updateCurrentDate(to: date)
        navigationController?.popViewController(animated: true)
    }
    
    func calendar(_ calendar: JTACMonthView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        currentMonth = visibleDates.monthDates[0].date
    }
    
    func calendar(_ calendar: JTACMonthView, headerViewForDateRange range: (start: Date, end: Date), at indexPath: IndexPath) -> JTACMonthReusableView {
        guard let header = calendar.dequeueReusableJTAppleSupplementaryView(withReuseIdentifier: CalendarViewController.headerReuseIdentifier, for: indexPath)
            as? WeekdaysHeader else {
                return JTACMonthReusableView()
        }
        return header
    }
    
    func calendarSizeForMonths(_ calendar: JTACMonthView?) -> MonthSize? {
        return MonthSize(defaultSize: 50)
    }
}

extension CalendarViewController {
    static let cellReuseIdentifier = "CalendarCell"
    static let headerReuseIdentifier = "WeekdaysHeader"
}

protocol CalendarViewControllerDelegate {
    func updateCurrentDate(to date: Date)
}
