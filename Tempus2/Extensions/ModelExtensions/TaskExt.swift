//
//  Task.swift
//  Tempus2
//
//  Created by Sola on 2021/8/30.
//  Copyright © 2021 Sola. All rights reserved.
//

import Foundation
import UIKit

extension Array where Element == Task {
    mutating func replace(_ oldTask: Task, with newTask: Task) {
        guard let oldTaskIndex = self.firstIndex(of: oldTask) else {
            return
        }
        self.replaceSubrange(oldTaskIndex...oldTaskIndex, with: [newTask])
    }
    
    mutating func remove(_ task: Task) {
        guard let index = self.firstIndex(of: task) else {
            return
        }
        self.remove(at: index)
    }
}

extension Task {
    var titleReprText: String {
        return !title.isEmpty
            ? title
            : "(No title)"
    }
    
    var timeReprText: String {
        return dateInterval.start.timeRepr() + "-" + dateInterval.end.timeRepr()
    }
    
    var timeAndDurationReprText: String {
        return timeReprText
            + " (\(dateInterval.duration.durationRepr))"
    }
    
    var dateAndTimeAndDurationReprText: String {
        return dateInterval.start.dateRepr()
            + " · "
            + timeAndDurationReprText
    }
    
    var homeEventLabelText: NSAttributedString {
        let attributedTitle = NSMutableAttributedString(
            string: titleReprText + "\n" + timeAndDurationReprText
        )
        if isCompleted {
            attributedTitle.setDeleteLine()
        }
        return attributedTitle
    }
    
    private var uncompletedTaskTitleAttrs: [NSAttributedString.Key: Any] {
        return [
            .font : Theme.title2Font
        ]
    }
    
    private var completedTaskTitleAttrs: [NSAttributedString.Key: Any] {
        return [
            .strikethroughStyle: NSUnderlineStyle.single.rawValue,
            .strikethroughColor: UIColor.black,
            .font : Theme.title2Font
        ]
    }
    
    private var taskDateAndTimeAttrs: [NSAttributedString.Key: Any] {
        return [
            .font : Theme.bodyFont
        ]
    }
    
    var titleAndDateTimeRepr: NSAttributedString {
        let repr = NSMutableAttributedString(
            string: titleReprText
                + "\n"
                + dateAndTimeAndDurationReprText
        )
        
        repr.set(
            attributes: isCompleted
                ? completedTaskTitleAttrs
                : uncompletedTaskTitleAttrs,
            for: titleReprText
        )
        repr.set(
            attributes: taskDateAndTimeAttrs,
            for: dateAndTimeAndDurationReprText
        )
        repr.set(
            attributes: [
                .paragraphStyle : {
                    let paraStyle = NSMutableParagraphStyle()
                    paraStyle.lineSpacing = 10
                    return paraStyle
                }()
            ]
        )
        return repr
    }
    
    private var descriptionAttrs: [NSAttributedString.Key: Any] {
        return [
            .font : Theme.bodyFont
        ]
    }
    
    var descriptionRepr: NSAttributedString {
        let repr = NSMutableAttributedString(string: description)
        repr.set(attributes: descriptionAttrs)
        return repr
    }
}
