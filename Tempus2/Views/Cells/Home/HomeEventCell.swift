//
//  TaskCell.swift
//  Tempus2
//
//  Created by Sola on 2021/8/30.
//  Copyright © 2021 Sola. All rights reserved.
//

import UIKit

class HomeEventCell: UIView {
        
    // MARK: - Models
    
    var task: Task!
    
    // MARK: - Controllers
    
    var delegate: HomeViewController!
    
    // MARK: - Views
    
    let mainView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.backgroundColor = Theme.lightBlueColor
        return view
    }()
    
    let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 12)
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
        
        mainView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped)))
    }
    
    func updateLayouts() {
        mainView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        label.snp.makeConstraints { (make) in
            make.top.bottom.leading.trailing.equalToSuperview().inset(10)
        }
    }
    
    func updateValues(task: Task, delegate: HomeViewController) {
        self.task = task
        self.delegate = delegate
        
        let attributedTitle = NSMutableAttributedString(string: task.title)
        if task.isCompleted {
            attributedTitle.setDeleteLine()
        }
        label.attributedText = attributedTitle
    }
}

extension HomeEventCell {
    @objc func tapped() {
        delegate.showEvent(of: task)
    }
}

protocol TaskCellDelegate {
    func showEvent(of task: Task)
}
