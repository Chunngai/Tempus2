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
            label.text = Task.typeStrings[type.rawValue]
        }
    }
    
    // MARK: - Controllers
    
    internal var delegate: EventEditViewController!
    
    // MARK: - Views
    
    internal let label: UILabel = {
        let label = UILabel()
        label.textColor = Theme.textColor
        label.textAlignment = .left
        label.font = Theme.bodyFont
        label.isUserInteractionEnabled = true
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
            label.addGestureRecognizer(UITapGestureRecognizer(
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
