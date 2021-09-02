//
//  Event.swift
//  Tempus2
//
//  Created by Sola on 2021/8/30.
//  Copyright © 2021 Sola. All rights reserved.
//

import Foundation

struct Task: Codable {
    var title: String
    // The dates in dateInterval are UTC.
    // Note that It's not appropriate to set a timezone for Date objs.
    var dateInterval: DateInterval
    var description: String
    
    var isCompleted: Bool
    
    // MARK: - IO
    
    // https://stackoverflow.com/questions/57665746/swift-5-xcode-11-betas-5-6-how-to-write-to-a-json-file
    static func loadTasks() -> [Task] {
        do {
            let fileURL = try FileManager.default
                .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                .appendingPathComponent("tasks.json")

            let data = try Data(contentsOf: fileURL)
            let tasks = try JSONDecoder().decode([Task].self, from: data)
            print(tasks)

            return tasks
        } catch {
            print(error)

            return []
        }
//        return [
//            Task(title: "Breakfast", dateInterval: DateInterval(start: Date(hour: 8, minute: 0), duration: 3600), description: "breakfast description", isCompleted: false),
//            Task(title: "AI course", dateInterval: DateInterval(start: Date(hour: 10, minute: 30), duration: 3600 * 1), description: "ai course description", isCompleted: false),
//            Task(title: "Math course", dateInterval: DateInterval(start: Date(hour: 13, minute: 0), duration: 3600 * 1.5), description: "math course description", isCompleted: true),
//        ]
    }
    
    static func save(_ tasks: [Task]) {
        do {
            let fileURL = try FileManager.default
                .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("tasks.json")

            try JSONEncoder().encode(tasks)
                .write(to: fileURL)
        } catch {
            print(error)
        }
    }
}

extension Task: Equatable {
    static func == (lhs: Task, rhs: Task) -> Bool {
        return lhs.title == rhs.title
            && lhs.dateInterval == rhs.dateInterval
            && lhs.description == rhs.description
    }
}

// TODO: tmp
extension Date {
    // Creates a date with hour and min.
    init(hour: Int, minute: Int) {
        var dateComponents = Calendar.current.dateComponents(in: TimeZone.current, from: Date())
        dateComponents.hour = hour
        dateComponents.minute = minute
    
        self = Calendar.current.date(from: dateComponents)!  // Timezone of the date generated is according to the system.
    }
}
