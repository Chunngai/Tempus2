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
    
    private var bottomHorizontalSeparator: Separator = {
        let separator = Separator()
        return separator
    }()
    
    private var leadingVerticalSeparator: Separator = {
        let separator = Separator()
        return separator
    }()
    
    private var trailingVerticalSeparator: Separator = {
        let separator = Separator()
        return separator
    }()
    
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
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(0.3)
        }
        
        bottomHorizontalSeparator.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(0.3)
        }
        
        leadingVerticalSeparator.snp.makeConstraints { (make) in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalTo(0.3)
        }
        
        trailingVerticalSeparator.snp.makeConstraints { (make) in
            make.trailing.top.bottom.equalToSuperview()
            make.width.equalTo(0.3)
        }
        
        havingTasksIndicator.snp.makeConstraints { (make) in
            make.top.equalTo(dateLabel.snp.bottom).offset(3)
            make.centerX.equalToSuperview()
            make.width.equalTo(CalendarCell.indicatorDiameter)
            make.height.equalTo(CalendarCell.indicatorDiameter)
        }
    }
    
    func updateValues(date: Date, cellState: CellState, hasTasks: Bool) {
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
    }
}

extension CalendarCell {
    static let indicatorDiameter: CGFloat = 9
}
