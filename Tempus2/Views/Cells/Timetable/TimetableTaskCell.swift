//
//  TimetableTaskCell.swift
//  Tempus2
//
//  Created by Sola on 2022/7/11.
//  Copyright © 2022 Sola. All rights reserved.
//

import UIKit

class TimetableTaskCell: UIView {
    
    // MARK: - Models
    
    private var task: Task! {
        didSet {
            label.text = task.title
        }
    }
    
    // MARK: - Delegates
    
    private var delegate: TimetableViewController!
    
    // MARK: - Views
    
    private var mainView: UIView = {
        let view = UIView()
        view.backgroundColor = Theme.lightBlue
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 5
        return view
    }()
    
    private var label: UILabel = {
        let label = UILabel()
        label.textColor = Theme.textColor
        label.font = Theme.smallerThanFootNoteFont
        label.numberOfLines = 0
        label.textAlignment = .left
        label.lineBreakMode = .byCharWrapping
        label.isUserInteractionEnabled = true
        return label
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        mainView.addGestureRecognizer({
            let gestureRecognizer = UITapGestureRecognizer()
            gestureRecognizer.numberOfTapsRequired = 1
            gestureRecognizer.addTarget(self, action: #selector(mainViewTapped))
            return gestureRecognizer
        }())
        addSubview(mainView)
        
        mainView.addSubview(label)
        
        updateViews()
        updateLayouts()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func updateViews() {
        
    }
    
    private func updateLayouts() {
        mainView.snp.makeConstraints { (make) in
            make.centerX.centerY.equalToSuperview()
            make.width.height.equalToSuperview().multipliedBy(0.98)
        }
        
        label.snp.makeConstraints { (make) in
            make.centerX.centerY.equalToSuperview()
            make.width.height.equalToSuperview().multipliedBy(0.85)
        }
    }
    
    internal func updateValues(task: Task, delegate: TimetableViewController) {
        self.task = task
        self.delegate = delegate
    }
}

extension TimetableTaskCell {
    
    // MARK: - Actions
    
    @objc private func mainViewTapped() {
        delegate.display(task)
    }
}
