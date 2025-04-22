//
//  TypeCell.swift
//  Tempus2
//
//  Created by Sola on 2022/4/10.
//  Copyright © 2022 Sola. All rights reserved.
//

import UIKit

class TypeCell: EventBaseCell {
    
    // MARK: - Models
    
    internal var type: Task.Type_! {
        didSet {
            textView.text = Task.typeStrings[type.rawValue]
        }
    }
    
    // MARK: - Controllers
    
    internal var delegate: EventEditViewController!
    
    // MARK: - Views
    
    internal let textView: UITextView = {  // For left alignment consistence.
        let textView = UITextView()
        textView.isScrollEnabled = false
        textView.textColor = Theme.textColor
        textView.textAlignment = .left
        textView.font = Theme.bodyFont
        textView.isEditable = false
        textView.sizeToFit()
        return textView
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
                
        rightView.addSubview(textView)
    }
    
    override func updateLayouts() {
        super.updateLayouts()
        
        iconImageView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            // Aligns with the top of the text view container inset.
            make.top.equalToSuperview().inset(TextViewWithPlaceHolder().textContainerInset.top)
            make.height.width.equalTo(Theme.bodyFont.lineHeight * 1.2)
        }
        
        textView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    func updateValues(iconName: String, type: Task.Type_, delegate: EventEditViewController, shouldDisplayAccessory: Bool = true) {
        super.updateValues(iconName: iconName)
        
        self.type = type
        self.delegate = delegate
        
        if shouldDisplayAccessory {
            accessoryType = .disclosureIndicator
            textView.addGestureRecognizer(UITapGestureRecognizer(
                target: self,
                action: #selector(cellTapped)
            ))
        } else {
            accessoryType = .none
        }
    }
}

extension TypeCell {
    
    // MARK: - Actions
    
    @objc func cellTapped() {
        let typeViewController = TypeViewController(style: .grouped)
        typeViewController.updateValues(type: type, delegate: self)
        delegate.navigationController?.pushViewController(typeViewController, animated: true)
    }
}

extension TypeCell: TypeViewControllerDelegate {
    
    func updateType(as taskType: Task.Type_) {
        self.type = taskType
        delegate.navigationController?.popViewController(animated: true)
    }
    
}
