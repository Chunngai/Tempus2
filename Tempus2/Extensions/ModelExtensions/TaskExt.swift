//
//  Task.swift
//  Tempus2
//
//  Created by Sola on 2021/8/30.
//  Copyright © 2021 Sola. All rights reserved.
//

import Foundation

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
    var homeEventLabelText: NSAttributedString {
        let attributedTitle = NSMutableAttributedString(string: title)
        if isCompleted {
            attributedTitle.setDeleteLine()
        }
        return attributedTitle
    }
}
