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
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateViews() {
        contentView.addSubview(dateLabel)
        
        dateLabel.snp.makeConstraints { (make) in
            make.centerX.centerY.equalToSuperview()
            make.width.height.equalTo(DateCell.diameter)
        }
    }
    
    func updateValues(text: String, backgroundColor: UIColor) {
        dateLabel.text = text
        dateLabel.backgroundColor = backgroundColor
    }
}

extension DateCell {
    static let diameter: CGFloat = 25
    
    static let bgColorOfToday = UIColor.systemBlue
    static let bgColorOfSelection = Theme.lightBlue
    static let commonBgColor = UIColor.white
}
