//
//  TimeLineTableViewCell.swift
//  Tempus2
//
//  Created by Sola on 2021/8/30.
//  Copyright © 2021 Sola. All rights reserved.
//

import UIKit
import SnapKit

class TimelineTableViewCell: UITableViewCell {
    
    open var timeLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.textColor = .black
        titleLabel.font = UIFont.preferredFont(forTextStyle: .title2)
        titleLabel.font = Theme.bodyFont
        titleLabel.sizeToFit()
        return titleLabel
    }()
    open var contentLabel: UILabel = {
        let descriptionLabel = UILabel()
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textColor = .gray
        descriptionLabel.font = UIFont.preferredFont(forTextStyle: .body)
        descriptionLabel.lineBreakMode = .byWordWrapping
        descriptionLabel.sizeToFit()
        return descriptionLabel
    }()
    open var durationLabel: UILabel = {
        let lineInfoLabel = UILabel()
        lineInfoLabel.font = UIFont.preferredFont(forTextStyle: .body)
        lineInfoLabel.textColor = .gray
        lineInfoLabel.textAlignment = .center
        lineInfoLabel.sizeToFit()
        return lineInfoLabel
    }()
        
    open var timePoint = TimelinePoint() {
        didSet {
            self.setNeedsDisplay()
        }
    }
    var endPoint = TimelinePoint() {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    open var timeline = Timeline() {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    // MARK: - Init
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        contentView.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().inset(20)
            make.leading.equalToSuperview().offset(timeline.leftMargin + 30)
            make.trailing.equalToSuperview().inset(30)
        }

        contentView.addSubview(contentLabel)
        contentLabel.snp.makeConstraints { (make) in
            make.top.equalTo(timeLabel.snp.bottom).offset(10)
            make.leading.equalTo(timeLabel.snp.leading)
            make.trailing.equalTo(timeLabel.snp.trailing)
            make.bottom.equalToSuperview()
        }
        
        contentView.addSubview(durationLabel)
        durationLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview()
            make.width.equalTo(timeline.leftMargin)
            make.top.equalTo(timeLabel.snp.bottom)
            make.bottom.equalToSuperview()
        }
    }

    override open func draw(_ rect: CGRect) {
        for layer in self.contentView.layer.sublayers! {
            if layer is CAShapeLayer {
                layer.removeFromSuperlayer()
            }
        }
        
        timePoint.position = CGPoint(
            x: timeline.leftMargin,
            y: timeLabel.frame.origin.y + timeLabel.intrinsicContentSize.height / 2
        )

        timeline.start = CGPoint(x: timeline.leftMargin, y: 0)
        timeline.middle = CGPoint(x: timeline.start.x, y: timePoint.position.y)
        timeline.end = CGPoint(x: timeline.start.x, y: self.bounds.size.height)
        timeline.draw(view: self.contentView)

//        print(timeline.start, timeline.middle, timeline.end)
//        print(contentView.frame)
        
        timePoint.draw(view: self.contentView)
    }
}
