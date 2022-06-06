//
//  AlarmCell.swift
//  Tempus2
//
//  Created by Sola on 2022/6/6.
//  Copyright © 2022 Sola. All rights reserved.
//

import UIKit

class AlarmCell: EventBaseCell {
    
    // MARK: - Controllers
    
    private var delegate: EventEditViewController!
    
    // MARK: - Views
    
    private let label: UITextView = {  // For left alignment consistence.
        let textView = UITextView()
        textView.text = "Alarm"
        textView.isScrollEnabled = false
        textView.textColor = Theme.textColor
        textView.textAlignment = .left
        textView.font = Theme.bodyFont
        textView.isEditable = false
        textView.isSelectable = false
        textView.sizeToFit()
        return textView
    }()
    
    let alarmSwitch: UISwitch = {
        let alarmSwitch = UISwitch()
        alarmSwitch.isOn = false
        return alarmSwitch
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
    
    override func updateViews() {
        super.updateViews()
        
        rightView.addSubview(label)
        rightView.addSubview(alarmSwitch)
    }
    
    override func updateLayouts() {
        super.updateLayouts()
        
        iconImageView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            // Aligns with the top of the text view container inset.
            make.top.equalToSuperview().inset(TextViewWithPlaceHolder().textContainerInset.top)
            make.height.width.equalTo(Theme.bodyFont.lineHeight * 1.2)
        }
        
        alarmSwitch.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview()
            make.width.equalTo(EventBaseCell.widthUnit)
        }
        
        label.snp.makeConstraints { (make) in
            make.top.bottom.leading.equalToSuperview()
            make.trailing.equalTo(alarmSwitch.snp.leading)
        }
    }
    
    func updateValues(
        iconName: String?,
        hasAlarm: Bool,
        delegate: EventEditViewController
    ) {
        super.updateValues(iconName: iconName)
        
        alarmSwitch.isOn = hasAlarm
        
        self.delegate = delegate
    }
}
