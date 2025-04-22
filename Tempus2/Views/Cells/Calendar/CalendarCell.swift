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
    }
    
    func updateValues(date: Date, cellState: CellState, tasks: [Task], shouldDrawBottomLine: Bool) {
        super.updateValues(
            date: date, 
            cellState: cellState,
            textColorForCurrentDay: Theme.highlightedTextColor, 
            textColorForCurrentMonthExceptCurrentDay: Theme.textColor,
            textColorForOtherMonths: Theme.weakTextColor
        )
                
        if !tasks.tasksOf(date).isEmpty {
            contentView.backgroundColor = Theme.lightBlue
            dateLabel.backgroundColor = Theme.lightBlue
        } else {
            contentView.backgroundColor = .white
            dateLabel.backgroundColor = .white
        }
        
        let attributedDateText = NSMutableAttributedString(string: dateLabel.text!)
        
        var textColor: UIColor
        if !tasks.unfinishedDues(on: date).isEmpty {
            textColor = .red
        } else {
            textColor = super.getColors(
                cellState: cellState,
                date: date,
                textColorForCurrentDay: Theme.highlightedTextColor,
                textColorForCurrentMonthExceptCurrentDay: Theme.textColor,
                textColorForOtherMonths: UIColor.lightGray
            )["textColor"]!
        }
        attributedDateText.setTextColor(with: textColor)
        
        if !tasks.unfinishedTasksOf(date).isEmpty {
            attributedDateText.setUnderline(color: textColor)
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
