//
//  ScheduleHeaderView.swift
//  Tempus2
//
//  Created by Sola on 2021/9/1.
//  Copyright © 2021 Sola. All rights reserved.
//

import UIKit

class ScheduleHeaderView: UIView {
    
    var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        return stack
    }()
    
    var horizontalSeparator: SeparationLine = {
        let line = SeparationLine()
        return line
    }()
    
    var verticalSeparator: SeparationLine = {
        let line = SeparationLine()
        return line
    }()
    
    let weekdayLabel: UILabel = {
        let label = UILabel()
        label.text = "WED"
        label.font = Theme.footNoteFont
        label.textAlignment = .center
        label.textColor = .systemBlue
        //        label.backgroundColor = .blue
        return label
    }()
    
    let roundView: UIView = {
        let view = UIView()
        return view
    }()
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.text = "1"
        label.textAlignment = .center
        label.backgroundColor = .systemBlue
        label.textColor = .white
        return label
    }()
    
    // MARK: - Init
    
    //    required init?(coder: NSCoder) {
    //        super.init(coder: coder)
    //
    //    }
    //
    //    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    //        super.init(style: style, reuseIdentifier: reuseIdentifier)
    //
    //        updateViews()
    //        updateLayouts()
    //    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        updateViews()
        updateLayouts()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func updateViews() {
        addSubview(stackView)
        
        stackView.addArrangedSubview(weekdayLabel)
        stackView.addArrangedSubview(roundView)
        
        roundView.addSubview(dateLabel)
        
        addSubview(horizontalSeparator)
        addSubview(verticalSeparator)
    }
    
    func updateLayouts() {
        stackView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(TimeSliceCell.labelLeadingOffset)
            make.width.equalTo(TimeSliceCell.labelWidth)
            make.top.equalToSuperview()
        }
        
        dateLabel.snp.makeConstraints { (make) in
            make.height.equalTo(ScheduleHeaderView.diameter)
            make.width.equalTo(ScheduleHeaderView.diameter)
            make.centerX.equalToSuperview()
        }
        dateLabel.layer.masksToBounds = true
        dateLabel.layer.cornerRadius = ScheduleHeaderView.diameter / 2
        
        horizontalSeparator.snp.makeConstraints { (make) in
            make.leading.equalToSuperview()
//            make.centerY.equalTo(stackView)
            make.trailing.equalToSuperview()
            make.height.equalTo(2)
            make.bottom.equalToSuperview()
        }
        
        verticalSeparator.snp.makeConstraints { (make) in
            make.leading.equalTo(stackView.snp.trailing).offset(TimeSliceCell.verticalSeparatorLeadingOffset)
            make.width.equalTo(0.6)
            make.height.equalToSuperview()
        }
    }
}

extension ScheduleHeaderView {
    static let diameter: CGFloat = CGFloat(Double(TimeSliceCell.labelWidth) / 1.3)
}
