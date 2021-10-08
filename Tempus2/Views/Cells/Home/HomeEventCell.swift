//
//  HomeEventCell.swift
//  Tempus2
//
//  Created by Sola on 2021/8/30.
//  Copyright © 2021 Sola. All rights reserved.
//

import UIKit

class HomeEventCell: UITableViewCell {
        
    // MARK: - Models
    
    private var task: Task!
    
    // MARK: - Controllers
    
    private var delegate: HomeViewController!
    
    // MARK: - Views
    
    internal let mainView: UILabel = {
        let view = UILabel()
        view.backgroundColor = Theme.homeEventCellColor
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        view.isUserInteractionEnabled = true
        return view
    }()
    
    internal let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.textAlignment = .center
        label.textColor = Theme.textColor
        label.font = UIFont.systemFont(ofSize: Theme.bodyFont.pointSize, weight: .light)
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textAlignment = .center
        label.textColor = Theme.textColor
        label.font = UIFont.systemFont(ofSize: Theme.footNoteFont.pointSize, weight: .light)
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
    
    func updateViews() {
        selectionStyle = .none
        
        addSubview(mainView)
        mainView.addSubview(titleLabel)
        mainView.addSubview(timeLabel)
        mainView.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(tapped)
        ))
    }
    
    func updateLayouts() {
        mainView.snp.makeConstraints { (make) in
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalToSuperview().multipliedBy(0.95)
            make.centerX.centerY.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.width.equalToSuperview().multipliedBy(0.9)
            make.top.equalToSuperview().inset(15)
            make.height.equalToSuperview().multipliedBy(0.3)
            make.centerX.equalToSuperview()
        }
        
        timeLabel.snp.makeConstraints { (make) in
            make.width.equalTo(titleLabel.snp.width)
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
        }
    }
    
    func updateValues(task: Task, delegate: HomeViewController) {
        self.task = task
        self.delegate = delegate
        
        mainView.backgroundColor = task.isCompleted
            ? Theme.homeEventCellCompletionColor
            : Theme.homeEventCellColor
        titleLabel.attributedText = task.titleAttrReprText
        timeLabel.text = task.timeAndDurationReprText
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
