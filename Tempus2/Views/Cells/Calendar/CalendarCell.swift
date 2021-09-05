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
    
    private var havingTasksIndicator: UILabel = {
        let label = UILabel()
        label.layer.masksToBounds = true
        label.layer.cornerRadius = CalendarCell.indicatorDiameter
        return label
    }()
    
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
        
        addSubview(havingTasksIndicator)
    }
    
    override func updateLayouts() {
        dateLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.height.equalTo(DateCell.diameter)
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
        
        leadingVerticalSeparator.snp.makeConstraints { (make) in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalTo(leadingVerticalSeparatorWidth)
        }
        
        trailingVerticalSeparator.snp.makeConstraints { (make) in
            make.trailing.top.bottom.equalToSuperview()
            make.width.equalTo(trailingVerticalSeparatorWidth)
        }
        
        havingTasksIndicator.snp.makeConstraints { (make) in
            make.top.equalTo(dateLabel.snp.bottom).offset(3)
            make.centerX.equalToSuperview()
            make.width.equalTo(CalendarCell.indicatorDiameter)
            make.height.equalTo(CalendarCell.indicatorDiameter)
        }
    }
    
    func updateValues(date: Date, cellState: CellState, hasTasks: Bool, shouldDrawBottomLine: Bool) {
        super.updateValues(date: date, cellState: cellState)
        
        dateLabel.text = cellState.text
        dateLabel.textColor = cellState.dateBelongsTo == .thisMonth
            ? Theme.textColor
            : Theme.weakTextColor
        
        if hasTasks {
            havingTasksIndicator.backgroundColor = Theme.lightBlue
        } else {
            havingTasksIndicator.backgroundColor = contentView.backgroundColor
        }
        
        if !shouldDrawBottomLine {
            bottomHorizontalSeparator.isHidden = true
        } else {
            bottomHorizontalSeparator.isHidden = false
        }
    }
}

extension CalendarCell {
    static let indicatorDiameter: CGFloat = 9
    static let lineWidth: CGFloat = 0.1
}
