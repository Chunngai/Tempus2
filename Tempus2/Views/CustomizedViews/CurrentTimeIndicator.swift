//
//  CurrentTimeIndicator.swift
//  Tempus2
//
//  Created by Sola on 2021/9/5.
//  Copyright © 2021 Sola. All rights reserved.
//

import UIKit

class CurrentTimeIndicator: UIView {
    
    let line: Separator = {
        let line = Separator(color: .black)
        return line
    }()
    
    let circle: UILabel = {
        let label = UILabel()
        label.layer.masksToBounds = true
        label.layer.cornerRadius = CurrentTimeIndicator.circleDiameter / 2
        label.backgroundColor = .black
        return label
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
    
    func updateViews() {
        addSubview(line)
        addSubview(circle)
    }
    
    func updateLayouts() {
        circle.snp.makeConstraints { (make) in
            make.leading.equalToSuperview()
            make.width.equalTo(CurrentTimeIndicator.circleDiameter)
            make.top.equalToSuperview()
            make.height.equalTo(CurrentTimeIndicator.circleDiameter)
        }
        
        line.snp.makeConstraints { (make) in
            make.leading.equalTo(circle.snp.trailing)
            make.trailing.equalToSuperview()
            make.centerY.equalTo(circle.snp.centerY)
            make.height.equalTo(0.6)            
        }
    }
}

extension CurrentTimeIndicator {
    static let circleDiameter: CGFloat = 9
}
