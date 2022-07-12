//
//  TimetableCell.swift
//  Tempus2
//
//  Created by Sola on 2022/7/10.
//  Copyright © 2022 Sola. All rights reserved.
//

import UIKit

class TimetableCell: UICollectionViewCell {
    
    // MARK: - Views
    
    internal lazy var label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: Theme.footNoteFont.pointSize, weight: .light)
        label.sizeToFit()
        return label
    }()
    
    // MARK: - Init
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(label)
        
        updateViews()
        updateLayouts()
    }
    
    private func updateViews() {

    }
    
    private func updateLayouts() {
        label.snp.makeConstraints { (make) in
            // Top & horizontally aligned.
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
        }
    }
    
    func updateValues(text: String) {
        label.text = text
    }
}
