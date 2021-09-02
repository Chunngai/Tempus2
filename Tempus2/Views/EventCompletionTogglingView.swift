//
//  EventCompletionSwitchingBottomView.swift
//  Tempus2
//
//  Created by Sola on 2021/9/2.
//  Copyright © 2021 Sola. All rights reserved.
//

import UIKit

class EventCompletionTogglingView: UIView {

    // MARK: - Controllers
    
    var delegate: EventDisplayViewController!
    
    let horizontalSeparator: SeparationLine = {
        let line = SeparationLine()
        return line
    }()
    
    let button: UIButton = {
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
    
    func updateViews() {
        backgroundColor = .white
        
        addSubview(horizontalSeparator)
        addSubview(button)
        button.addTarget(self, action: #selector(toggleCompletion), for: .touchUpInside)
    }

    func updateLayouts() {
        horizontalSeparator.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(1)
        }
        
        button.snp.makeConstraints { (make) in
            make.top.equalToSuperview().inset(10)
            make.trailing.equalToSuperview()
            make.width.equalTo(130)
        }
    }
    
    func updateValues(delegate: EventDisplayViewController) {
        self.delegate = delegate
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
