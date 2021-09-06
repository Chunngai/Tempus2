//
//  HomeEventCell.swift
//  Tempus2
//
//  Created by Sola on 2021/8/30.
//  Copyright © 2021 Sola. All rights reserved.
//

import UIKit

class HomeEventCell: UIView {
        
    // MARK: - Models
    
    private var task: Task!
    
    // MARK: - Controllers
    
    private var delegate: HomeViewController!
    
    // MARK: - Views
    
    private let mainView: UIView = {
        let view = UIView()
        view.backgroundColor = Theme.homeEventCellColor
        return view
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = Theme.footNoteFont
        label.textAlignment = .left
        label.textColor = Theme.textColor
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
        addSubview(mainView)
        mainView.addSubview(label)
        
        mainView.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(tapped)
        ))
    }
    
    func updateLayouts() {
        mainView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        label.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
        }
    }
    
    func updateValues(task: Task, delegate: HomeViewController, inOneLine: Bool) {
        self.task = task
        self.delegate = delegate
        
        label.attributedText = inOneLine
            ? task.homeEventOneLineLabelText
            : task.homeEventMultilineLabelText
    }
}

extension HomeEventCell {
    @objc private func tapped() {
        delegate.display(task)
    }
}

protocol HomeEventCellDelegate {
    func display(_ task: Task)
}
