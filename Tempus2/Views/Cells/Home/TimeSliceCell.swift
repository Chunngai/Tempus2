//
//  TaskCell.swift
//  Tempus2
//
//  Created by Sola on 2021/8/30.
//  Copyright © 2021 Sola. All rights reserved.
//

import UIKit
import SnapKit

class TimeSliceCell: UITableViewCell {
    
    // MARK: - Views
    
    var timeSliceLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = Theme.footNoteFont
        label.textColor = Theme.weakTextColor
        label.sizeToFit()
        return label
    }()
    
    var horizontalSeparator: SeparationLine = {
        let line = SeparationLine()
        return line
    }()
    
    var verticalSeparator: SeparationLine = {
        let line = SeparationLine()
        return line
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
    
    func updateViews() {
        selectionStyle = .none
        
        contentView.addSubview(timeSliceLabel)
        
        contentView.addSubview(horizontalSeparator)
        contentView.addSubview(verticalSeparator)
    }
    
    func updateLayouts() {
        timeSliceLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(TimeSliceCell.timeSliceLabelLeadingOffset)
            make.width.equalTo(TimeSliceCell.timeSliceLabelWidth)
            make.top.equalToSuperview()
        }
        
        horizontalSeparator.snp.makeConstraints { (make) in
            make.leading.equalTo(timeSliceLabel.snp.trailing)
            make.centerY.equalTo(timeSliceLabel)
            make.trailing.equalToSuperview()
            make.height.equalTo(0.6)
        }
        
        verticalSeparator.snp.makeConstraints { (make) in
            make.leading.equalTo(horizontalSeparator.snp.leading).offset(TimeSliceCell.verticalSeparatorLeadingOffset)
            make.width.equalTo(0.6)
            make.height.equalToSuperview()
        }
    }
    
    func updateValues(time: String) {
        timeSliceLabel.text = time
    }
}

extension TimeSliceCell {
    static var timeSliceLabelLeadingOffset = 10
    static var timeSliceLabelWidth = 50
    static var verticalSeparatorLeadingOffset = TimeSliceCell.timeSliceLabelLeadingOffset
}
