//
//  CalendarCell.swift
//  Tempus2
//
//  Created by Sola on 2021/9/5.
//  Copyright © 2021 Sola. All rights reserved.
//

import UIKit
import JTAppleCalendar

class CalendarCell: DateCell {
    
    private var topHorizontalSeparator: Separator = {
        let separator = Separator()
        return separator
    }()
    private var topHorizontalSeparatorWidth: CGFloat = CalendarCell.lineWidth
    
    private var bottomHorizontalSeparator: Separator = {
        let separator = Separator()
        return separator
    }()
    private var bottomHorizontalSeparatorWidth: CGFloat = CalendarCell.lineWidth
    
    private var leadingVerticalSeparator: Separator = {
        let separator = Separator()
        return separator
    }()
    private var leadingVerticalSeparatorWidth: CGFloat = CalendarCell.lineWidth
    
    private var trailingVerticalSeparator: Separator = {
        let separator = Separator()
        return separator
    }()
    private var trailingVerticalSeparatorWidth: CGFloat = CalendarCell.lineWidth
    
    // MARK: - Init
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        updateViews()
        updateLayouts()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateViews() {
        super.updateViews()
        
        addSubview(topHorizontalSeparator)
        addSubview(bottomHorizontalSeparator)
        addSubview(leadingVerticalSeparator)
        addSubview(trailingVerticalSeparator)        
    }
    
    override func updateLayouts() {
        dateLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.height.equalTo(DateCell.diameter)
            make.top.equalToSuperview().inset(2)
        }
        
        topHorizontalSeparator.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview().inset(topHorizontalSeparatorWidth)
            make.height.equalTo(topHorizontalSeparatorWidth)
        }
        
        bottomHorizontalSeparator.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(bottomHorizontalSeparatorWidth)
            make.height.equalTo(bottomHorizontalSeparatorWidth)
        }
//
//        leadingVerticalSeparator.snp.makeConstraints { (make) in
//            make.leading.top.bottom.equalToSuperview()
//            make.width.equalTo(leadingVerticalSeparatorWidth)
//        }
//
//        trailingVerticalSeparator.snp.makeConstraints { (make) in
//            make.trailing.top.bottom.equalToSuperview()
//            make.width.equalTo(trailingVerticalSeparatorWidth)
//        }
    }
    
    func updateValues(date: Date, cellState: CellState, tasks: [Task], shouldDrawBottomLine: Bool) {
        super.updateValues(
            date: date, cellState: cellState,
            textColorForCurrentDay: Theme.highlightedTextColor, textColorForCurrentMonthExceptCurrentDay: Theme.textColor, textColorForOtherMonths: UIColor.lightGray
        )
                
        if !tasks.tasksOf(date).isEmpty {
            if !tasks.unfinishedTasksOf(date).isEmpty {
                contentView.backgroundColor = Theme.lightBlue
                dateLabel.backgroundColor = Theme.lightBlue
            } else {
                contentView.backgroundColor = Theme.lightBlue2
                dateLabel.backgroundColor = Theme.lightBlue2
            }
        } else {
            contentView.backgroundColor = .white
            dateLabel.backgroundColor = .white
        }
        
        let attributedDateText = NSMutableAttributedString(string: dateLabel.text!)
        if !tasks.unfinishedDues(on: date).isEmpty {
            attributedDateText.setUnderline(style: NSUnderlineStyle.thick, color: .red)
        } else {
            attributedDateText.removeUnderline()
        }
        dateLabel.attributedText = attributedDateText
        
        if !shouldDrawBottomLine {
            bottomHorizontalSeparator.isHidden = true
        } else {
            bottomHorizontalSeparator.isHidden = false
        }
    }
}

extension CalendarCell {
    static let lineWidth: CGFloat = 0.1
}
