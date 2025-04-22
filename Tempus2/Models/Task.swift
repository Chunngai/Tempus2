//
//  Event.swift
//  Tempus2
//
//  Created by Sola on 2021/8/30.
//  Copyright © 2021 Sola. All rights reserved.
//

import Foundation

struct Task: Codable {
    
    var identifier: String
    
    var title: String
    
    var type: Task.Type_
    
    // The dates in dateInterval are UTC.
    // Note that It's not appropriate to set a timezone for Date objs.
    var dateInterval: DateInterval
    
    var hasAlarm: Bool
    
    var location: String
    
    var description: String
    
    var isCompleted: Bool
    
    var isTimetableTask: Bool
    
    // MARK: - Init
    
    init(identifier: String?, title: String, type: Task.Type_, dateInterval: DateInterval, hasAlarm: Bool, location: String, description: String, isCompleted: Bool, isTimetableTask: Bool) {
        self.identifier = identifier ?? UUID().uuidString
        
        self.title = title
        self.type = type
        self.dateInterval = dateInterval
        self.hasAlarm = hasAlarm
        self.location = location
        self.description = description
        self.isCompleted = isCompleted
        self.isTimetableTask = isTimetableTask
    }
    
    init(title: String, type: Task.Type_, dateInterval: DateInterval, hasAlarm: Bool, location: String, description: String, isCompleted: Bool, isTimetableTask: Bool) {
        self.init(
            identifier: nil,
            title: title,
            type: type,
            dateInterval: dateInterval,
            hasAlarm: hasAlarm,
            location: location,
            description: description,
            isCompleted: isCompleted,
            isTimetableTask: isTimetableTask
        )
    }
}

extension Task {
    
    enum Type_: Int, Codable {
        case event  // Time period.
        case task  // Time point.
        case anytime  // Anytime of the day.
        case due
    }
    
    static let typeStrings: [String] = [
        "Event - Time Period",
        "Event - Time Point",
        "Event - Within the Day",
        "Due"
    ]
    
}

extension Task {
    
    // MARK: - IO
    
    // https://stackoverflow.com/questions/57665746/swift-5-xcode-11-betas-5-6-how-to-write-to-a-json-file
    static func load() -> [Task] {
        do {
            let fileURL = try FileManager
                .default
                .url(
                    for: .applicationSupportDirectory,
                    in: .userDomainMask,
                    appropriateFor: nil,
                    create: false
            )
                .appendingPathComponent("tasks.json")
            
            let data = try Data(contentsOf: fileURL)
            let tasks = try JSONDecoder().decode([Task].self, from: data)
            
            return tasks
        } catch {
            print(error)
            exit(1)
        }
    }
    static func save(_ tasks: inout [Task]) {
        tasks.sort()
        do {
            let fileURL = try FileManager
                .default
                .url(
                    for: .applicationSupportDirectory,
                    in: .userDomainMask,
                    appropriateFor: nil,
                    create: true
            )
                .appendingPathComponent("tasks.json")
            
            try JSONEncoder()
                .encode(tasks)
                .write(to: fileURL)
        } catch {
            print(error)
            exit(1)
        }
    }
}

extension Task: Equatable {
    
    // MARK: - Equatable
    
    static func == (lhs: Task, rhs: Task) -> Bool {
        // No overlap in any of the two tasks.
        return lhs.identifier == rhs.identifier
    }
}

extension Task {
    
    // MARK: - Samples
    
    private func makeDate(hour: Int, minute: Int) -> Date {
        var dateComponents = Calendar
            .current
            .dateComponents(
                in: TimeZone.current,
                from: Date()
        )
        
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        return Calendar.current.date(from: dateComponents) ?? Date()
    }
    
    func loadSamples() -> [Task] {
        return [
            Task(
                title: "Breakfast",
                type: .event,
                dateInterval: DateInterval(
                    start: makeDate(hour: 8, minute: 0),
                    duration: TimeInterval.Hour * 1
                ),
                hasAlarm: false,
                location: "Cafeteria",
                description: "breakfast description",
                isCompleted: false,
                isTimetableTask: false
            ),
            Task(
                title: "AI course",
                type: .event,
                dateInterval: DateInterval(
                    start: makeDate(hour: 10, minute: 30),
                    duration: TimeInterval.Hour * 1),
                hasAlarm: false,
                location: "E201",
                description: "ai course description",
                isCompleted: false,
                isTimetableTask: false
            ),
            Task(
                title: "Math course",
                type: .event,
                dateInterval: DateInterval(
                    start: makeDate(hour: 13, minute: 0),
                    duration: TimeInterval.Hour * 1.5),
                hasAlarm: false,
                location: "F203",
                description: "math course description",
                isCompleted: true,
                isTimetableTask: false
            )
        ]
    }
}
