//
//  EventCompletionTogglingView.swift
//  Tempus2
//
//  Created by Sola on 2021/9/2.
//  Copyright © 2021 Sola. All rights reserved.
//

import UIKit

class EventCompletionTogglingView: UIView {

    internal var isCompleted: Bool! {
        didSet {
            var buttonTitle: String
            if !isCompleted {
                buttonTitle = "Mark completed"
            } else {
                buttonTitle = "Mark uncompleted"
            }
            completionTogglingButton.setTitle(
                buttonTitle,
                for: .normal
            )
        }
    }
    
    // MARK: - Controllers
    
    private var delegate: EventDisplayViewController!
    
    private let horizontalSeparator: Separator = {
        let line = Separator()
        return line
    }()
    
    private let completionTogglingButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = Theme.footNoteFont
        button.setTitleColor(Theme.highlightedTextColor, for: .normal)
        button.titleLabel?.textAlignment = .right
        return button
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
    
    private func updateViews() {
        backgroundColor = .white
        
        addSubview(horizontalSeparator)
        
        addSubview(completionTogglingButton)
        completionTogglingButton.addTarget(
            self,
            action: #selector(toggleCompletion),
            for: .touchUpInside
        )
    }

    private func updateLayouts() {
        horizontalSeparator.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(1)
        }
        
        completionTogglingButton.snp.makeConstraints { (make) in
            make.top.equalToSuperview().inset(10)
            make.trailing.equalToSuperview().inset(10)
            make.width.equalTo(130)
        }
    }
    
    func updateValues(isCompleted: Bool = false, delegate: EventDisplayViewController) {
        self.delegate = delegate
        self.isCompleted = isCompleted
    }
}

extension EventCompletionTogglingView {
    @objc func toggleCompletion() {
        delegate.toggleCompletion()
    }
}

protocol EventCompletionTogglingViewDelegate {
    func toggleCompletion()
}
