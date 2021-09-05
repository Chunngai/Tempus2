//
//  DateCell.swift
//  Tempus2
//
//  Created by Sola on 2021/8/31.
//  Copyright © 2021 Sola. All rights reserved.
//

import UIKit
import JTAppleCalendar

class DateCell: JTACDayCell {
    
    // MARK: - Views
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = Theme.footNoteFont
        label.layer.masksToBounds = true
        label.layer.cornerRadius = DateCell.diameter / 2
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
    
    func updateViews() {
        contentView.addSubview(dateLabel)
    }
    
    func updateLayouts() {
        dateLabel.snp.makeConstraints { (make) in
            make.centerX.centerY.equalToSuperview()
            make.width.height.equalTo(DateCell.diameter)
        }
    }
    
    func updateValues(date: Date, cellState: CellState) {
        dateLabel.text = cellState.dateBelongsTo == .thisMonth
            ? cellState.text
            : ""
        dateLabel.backgroundColor = (
            Calendar.current.isDateInToday(date)
                && cellState.dateBelongsTo == .thisMonth
            )
            ? DateCell.todayColor
            : DateCell.commonColor
    }
}

extension DateCell {
    func configSelection(of state: CellState) {
        if state.isSelected {
            if !Calendar.current.isDateInToday(state.date) {
                dateLabel.backgroundColor = DateCell.selectedColor
            }
        } else {
            if !Calendar.current.isDateInToday(state.date) {
                dateLabel.backgroundColor = DateCell.commonColor
            }
        }
        
    }
}

extension DateCell {
    static let diameter: CGFloat = 25
    
    static let todayColor = UIColor.systemBlue
    static let selectedColor = Theme.dateCellBgColor
    static let commonColor = UIColor.white
}
