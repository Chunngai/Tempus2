//
//  DateHeader.swift
//  Tempus2
//
//  Created by Sola on 2021/9/1.
//  Copyright © 2021 Sola. All rights reserved.
//

import UIKit
import JTAppleCalendar

class WeekdaysHeader: JTACMonthReusableView {
    
    let weekdays: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        for weekday in DateFormatter().veryShortWeekdaySymbols {
            let label = UILabel()
            label.textAlignment = .center
            label.font = Theme.footNoteFont
            label.text = weekday
            stackView.addArrangedSubview(label)
        }
        
        return stackView
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        updateViews()
        updateLayouts()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func updateViews() {
        addSubview(weekdays)
    }
     
    func updateLayouts() {
        weekdays.snp.makeConstraints { (make) in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
    }
}
