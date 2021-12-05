//
//  EventDisplayCell.swift
//  Tempus2
//
//  Created by Sola on 2021/9/1.
//  Copyright © 2021 Sola. All rights reserved.
//

import UIKit

class EventDisplayCell: EventBaseCell {
    
    private var label: UILabel = {
        let label = UILabel()
        label.font = Theme.bodyFont
        label.numberOfLines = 0
        label.sizeToFit()
        return label
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
    }
    
    override func updateLayouts() {
        super.updateLayouts()
        
        label.snp.makeConstraints { (make) in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview().inset(5)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    func updateValues(iconName: String?, attributedText: NSAttributedString) {
        super.updateValues(iconName: iconName)
        
        label.attributedText = attributedText
    }
}
