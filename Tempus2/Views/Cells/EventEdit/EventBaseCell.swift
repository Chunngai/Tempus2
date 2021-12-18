//
//  EventBaseCell.swift
//  Tempus2
//
//  Created by Sola on 2021/9/3.
//  Copyright © 2021 Sola. All rights reserved.
//

import UIKit

class EventBaseCell: UITableViewCell {
    
    // MARK: - Views
    
    internal var iconImageView = UIImageView()
    private let iconBackView: UILabel = {
        let label = UILabel()
        return label
    }()
    
    internal var rightView: UIView = {
        let view = UIView()
        return view
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
        
        contentView.addSubview(iconBackView)
        iconBackView.addSubview(iconImageView)
        
        contentView.addSubview(rightView)
    }
    
    func updateLayouts() {
        iconBackView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview()
            make.top.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().inset(10)
            make.width.equalTo(EventBaseCell.widthUnit)
        }
        
        iconImageView.snp.makeConstraints { (make) in
//            make.centerY.centerX.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.width.equalTo(Theme.bodyFont.lineHeight * 1.2)
        }
        
        rightView.snp.makeConstraints { (make) in
            make.leading.equalTo(iconBackView.snp.trailing)
            make.trailing.equalToSuperview()
            make.top.equalTo(iconBackView.snp.top)
            make.bottom.equalTo(iconBackView.snp.bottom)
        }
    }
    
    func updateValues(iconName: String?) {
        if let iconName = iconName {
            iconImageView.image = UIImage(imageLiteralResourceName: iconName)
                .convertTo(color: Theme.weakTextColor)
        } else {
            iconImageView.image = nil
        }
    }
}

extension EventBaseCell {
    static let widthUnit: CGFloat = UIScreen.main.bounds.width * CGFloat(1) / 7
}
