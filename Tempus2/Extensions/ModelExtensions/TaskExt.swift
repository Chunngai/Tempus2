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
        
    // TODO: - Use another way to get tasks of the same date.
    func tasksOf(_ date: Date) -> [Task] {
        return self.compactMap { (task) -> Task? in
            if Calendar.current.isDate(
                task.dateInterval.start,
                inSameDayAs: date
            ) {
                return task
            } else {
                return nil
            }
        }
    }
}

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
    
    // MARK: - Title Representations
    
    var titleRepresentation: String {
        return !title.isEmpty
            ? title
            : "(No title)"
    }
    
    var titleAttributedRepresentation: NSAttributedString {
        let attrString = NSMutableAttributedString(string: titleRepresentation)
        if isCompleted {
            attrString.setDeleteLine()
        }
        return attrString
    }
}

extension Task {
    
    // MARK: - DateInterval Representations
    
    var timeReprsentation: String {
        return dateInterval.start.timeRepresentation()
            + " - "
            + dateInterval.end.timeRepresentation()
    }
    
    var timeAndDurationRepresentation: String {        
        // Instead of `if dateInterval.duration == 0`,
        // use the code below instead.
        if dateInterval.duration < TimeInterval.secondsOfOneMinute {
            return String(timeReprsentation.split(separator: "-")[0]).trimmingWhitespacesAndNewlines()
        } else {
            return timeReprsentation
                + " "
                + "(\(dateInterval.duration.durationRepr))"
        }
    }
    
    var dateAndTimeAndDurationRepresentation: String {
        return dateInterval.start.dateRepresentation()
            + " · "
            + timeAndDurationRepresentation
    }
}

extension Task {
    
    // MARK: - Task Representations
    
    private var uncompletedTextAttributes: [NSAttributedString.Key: Any] {
        return [
            .font : Theme.title2Font
        ]
    }
    
    private var completedTextAttributes: [NSAttributedString.Key: Any] {
        return [
            .strikethroughStyle: NSUnderlineStyle.single.rawValue,
            .strikethroughColor: UIColor.black,
            .font : Theme.title2Font
        ]
    }
    
    private var dateAndTimeAndDurationTextAttributes: [NSAttributedString.Key: Any] {
        return [
            .font : Theme.bodyFont
        ]
    }
    
    private var taskTextAttributes: [NSAttributedString.Key: Any] {
        return [
            .paragraphStyle : {
                let paraStyle = NSMutableParagraphStyle()
                paraStyle.lineSpacing = 10
                return paraStyle
            }()
        ]
    }
    
    var attributedRepresentation: NSAttributedString {
        let repr = NSMutableAttributedString(
            string: titleRepresentation
                + "\n"
                + dateAndTimeAndDurationRepresentation
        )
        
        repr.set(
            attributes: isCompleted
                ? completedTextAttributes
                : uncompletedTextAttributes,
            for: titleRepresentation
        )
        repr.set(
            attributes: dateAndTimeAndDurationTextAttributes,
            for: dateAndTimeAndDurationRepresentation
        )
        repr.set(
            attributes: taskTextAttributes
        )
        
        return repr
    }
}

extension Task {
    
    // MARK: - Description representations
    
    private var descriptionTextAttributes: [NSAttributedString.Key: Any] {
        return [
            .font : Theme.bodyFont
        ]
    }
    
    var descriptionAttributedRepresentation: NSAttributedString {
        let repr = NSMutableAttributedString(string: description)
        repr.set(attributes: descriptionTextAttributes)
        return repr
    }
}
