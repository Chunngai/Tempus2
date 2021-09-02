////
////  invalidDateIntervalWarningView.swift
////  Tempus2
////
////  Created by Sola on 2021/9/2.
////  Copyright © 2021 Sola. All rights reserved.
////
//
//import UIKit
//
//class InvalidDateIntervalWarningView: UIView {
//    
//    let label: UILabel = {
//        let label = UILabel()
//        label.textColor = UIColor.white
//        label.backgroundColor = .darkGray
//        label.font = Theme.footNoteFont
//        label.text = "The event end time cannot be set before the start time."
//        return label
//    }()
//    
//    // MARK: - Init
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        
//        updateViews()
//        updateLayouts()
//    }
//    
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//    }
//    
//    func updateViews() {
//        backgroundColor = .darkGray
//        
//        addSubview(label)
//    }
//    
//    func updateLayouts() {
//        label.snp.makeConstraints { (make) in
//            make.top.leading.trailing.equalToSuperview().inset(30)
//        }
//    }
//}
