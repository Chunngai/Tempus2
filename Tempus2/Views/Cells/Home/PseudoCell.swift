//
//  PseudoCell.swift
//  Tempus2
//
//  Created by Sola on 2021/10/8.
//  Copyright © 2021 Sola. All rights reserved.
//

import UIKit

class PseudoCell: HomeEventCell {
    
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
        
        mainView.backgroundColor = Theme.pseudoCellColor

        titleLabel.text = "No task"
    }
    
    override func updateLayouts() {
        mainView.snp.makeConstraints { (make) in
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalToSuperview().multipliedBy(0.95)
            make.centerX.centerY.equalToSuperview()
        }
        
        titleStackView.snp.makeConstraints { (make) in
            make.height.equalToSuperview().multipliedBy(0.3)
            make.centerX.centerY.equalToSuperview()
        }
        descriptionImageView.isHidden = true
        alarmImageView.isHidden = true
    }
}

extension PseudoCell {
    @objc private func tapped() {
        
    }
}
