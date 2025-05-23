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
    // TODO: - Rename to avoid ambiguity with .task.
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
    
    func normalTasksOf(_ date: Date) -> [Task] {
        return tasksOf(date).compactMap { (task) -> Task? in
            if !task.isTimetableTask {
                return task
            } else {
                return nil
            }
        }
    }
    
    var normalTasksOfToday: [Task] {
        return self.normalTasksOf(Date())
    }
    
    func timetableTasksOf(_ date: Date) -> [Task] {
        return tasksOf(date).compactMap { (task) -> Task? in
            if task.isTimetableTask {
                return task
            } else {
                return nil
            }
        }
    }
    
    func duesOf(_ date: Date) -> [Task] {
        return self.tasksOf(date).compactMap { (task) -> Task? in
            if task.type == .due {
                return task
            } else {
                return nil
            }
        }
    }
}

extension Array where Element == Task {
    
    var timetableTasks: [Task] {
        return self.compactMap { (task) -> Task? in
            if task.isTimetableTask {
                return task
            } else {
                return nil
            }
        }
    }
}

extension Array where Element == Task {
    
    mutating func sort() {
        self.sort { (task1, task2) -> Bool in
            if task1.dateInterval.start != task2.dateInterval.start {
                return task1.dateInterval.start < task2.dateInterval.start
            } else {
                return task1.dateInterval.end < task2.dateInterval.end
            }
        }
    }
}

extension Array where Element == Task {
    
    func unfinishedTasksOf(_ date: Date) -> [Task] {
        return self.tasksOf(date).compactMap { (task) -> Task? in
            if !task.isCompleted && !task.isTimetableTask {
                return task
            } else {
                return nil
            }
        }
    }
    
    func unfinishedDues(on date: Date) -> [Task] {
        return self.duesOf(date).compactMap { (task) -> Task? in
            if !task.isCompleted && !task.isTimetableTask {
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

extension Array where Element == Task {
    func taskConflicted(with newTask: Task) -> Task? {
        for task in self {
            if task.identifier == newTask.identifier {
                continue
            }
            
            if let intersectionInterval = task.dateInterval.intersection(with: newTask.dateInterval) {
                let componentsToCompare: [Calendar.Component] = [.year, .month, .day, .hour, .minute]
                if intersectionInterval.start.get(componentsToCompare) == intersectionInterval.end.get(componentsToCompare) {
                    // 8:00-8:30, 8:30-9:30. Has intersection but is allowed.
                    continue
                }
                
                return task
            }
        }
        return nil
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
        
        attrString.setTextColor(with: Theme.textColor)
        if type == .due {
            if !isCompleted {
                attrString.setTextColor(with: .red)
            }
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
        
        if type == .event {
            return (
                timeReprsentation
                + " "
                + "(\(dateInterval.duration.durationRepr))"
            )
        } else if type == .task || type == .due {
            let s = String(timeReprsentation.split(separator: "-")[0]).trimmingWhitespacesAndNewlines()
            if type == .task {
                return s
            } else {
                return "Before \(s)"
            }
        } else if type == .anytime {
            return "Within the Day"
        } else {
            return ""
        }
    }
    
    var dateAndTimeAndDurationRepresentation: String {
        return dateInterval.start.dateRepresentation()
            + " · "
            + timeAndDurationRepresentation
    }
}

extension Task {
    
    // MARK: - Location Representations
    
    var locationRepresentation: String {
        if !location.trimmingWhitespacesAndNewlines().isEmpty {
            return "@ \(location)"
        } else {
            return ""
        }
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
            string: (
                titleRepresentation
                    + "\n"
                    + dateAndTimeAndDurationRepresentation
                    + "\n"
                    + locationRepresentation
                ).trimmingWhitespacesAndNewlines()
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

extension Task {
    
    var dateAndTimeAndDurationRepresentationForTimetableTask: String {
        return dateInterval.start.dateRepresentation(ofFormat: "EE")
            + " · "
            + timeAndDurationRepresentation
    }
    
    var attributedRepresentationForTimetableTask: NSAttributedString {
        let repr = NSMutableAttributedString(
            string: (
                titleRepresentation
                    + "\n"
                    + dateAndTimeAndDurationRepresentationForTimetableTask
                    + "\n"
                    + locationRepresentation
                ).trimmingWhitespacesAndNewlines()
        )
        
        repr.set(
            attributes: isCompleted
                ? completedTextAttributes
                : uncompletedTextAttributes,
            for: titleRepresentation
        )
        repr.set(
            attributes: dateAndTimeAndDurationTextAttributes,
            for: dateAndTimeAndDurationRepresentationForTimetableTask
        )
        repr.set(
            attributes: taskTextAttributes
        )
        
        return repr
    }
    
}
