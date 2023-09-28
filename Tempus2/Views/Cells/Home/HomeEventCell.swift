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
    
    private var task: Task! {
        didSet {
            mainView.backgroundColor = task.isCompleted
                ? Theme.homeEventCellCompletionColor
                : Theme.homeEventCellColor
            titleLabel.attributedText = task.titleAttributedRepresentation
            descriptionImageView.isHidden = task.description.trimmingWhitespacesAndNewlines().isEmpty
            alarmImageView.isHidden = !task.hasAlarm
            timeAndLocationLabel.text = task.timeAndDurationRepresentation + " " + task.locationRepresentation
        }
    }
    
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
    
    internal lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: Theme.bodyFont.pointSize, weight: .light)
        return label
    }()
    
    internal lazy var descriptionImageView = UIImageView(image: UIImage(imageLiteralResourceName: "description"))
    internal lazy var alarmImageView = UIImageView(image: UIImage(imageLiteralResourceName: "alarm"))
    
    internal lazy var titleStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, descriptionImageView, alarmImageView])
        stack.alignment = .center
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.spacing = 10
        return stack
    }()
    
    private let timeAndLocationLabel: UILabel = {
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
        
        contentView.addSubview(mainView)
        mainView.addSubview(titleStackView)
        mainView.addSubview(timeAndLocationLabel)
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
        
        titleStackView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().inset(15)
            make.height.equalToSuperview().multipliedBy(0.3)
            make.centerX.equalToSuperview()
        }
        descriptionImageView.snp.makeConstraints { (make) in
            make.height.width.equalTo(Theme.bodyFont.lineHeight)
        }
        alarmImageView.snp.makeConstraints { (make) in
            make.height.width.equalTo(Theme.bodyFont.lineHeight)
        }
        
        timeAndLocationLabel.snp.makeConstraints { (make) in
            make.width.equalToSuperview().multipliedBy(0.9)
            make.centerX.equalToSuperview()
            make.top.equalTo(titleStackView.snp.bottom).offset(5)
        }
    }
    
    func updateValues(task: Task, delegate: HomeViewController) {
        self.task = task
        self.delegate = delegate
    }
}

extension HomeEventCell {
    @objc private func tapped() {
        guard delegate != nil else {
            return
        }
        
        delegate.display(task)
    }
}
