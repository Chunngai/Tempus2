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
    
    // The dates in dateInterval are UTC.
    // Note that It's not appropriate to set a timezone for Date objs.
    var dateInterval: DateInterval
    
    var description: String
    
    var isCompleted: Bool
    
    // MARK: - Init
    
    init(identifier: String?, title: String, dateInterval: DateInterval, description: String, isCompleted: Bool) {
        self.identifier = identifier ?? String(Date().hashValue)
        
        self.title = title
        self.dateInterval = dateInterval
        self.description = description
        self.isCompleted = isCompleted
    }
    
    init(title: String, dateInterval: DateInterval, description: String, isCompleted: Bool) {
        self.init(
            identifier: nil,
            title: title,
            dateInterval: dateInterval,
            description: description,
            isCompleted: isCompleted
        )
    }
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
            
            return []
        }
    }
    static func save(_ tasks: [Task]) {
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
        }
    }
}

extension Task: Equatable {
    
    // MARK: - Equatable
    
    static func == (lhs: Task, rhs: Task) -> Bool {
        // No overlap in any of the two tasks.
        // TODO: - Using an identifier or `dateInterval` may be enough.
        return lhs.dateInterval == rhs.dateInterval
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
                dateInterval: DateInterval(
                    start: makeDate(hour: 8, minute: 0),
                    duration: TimeInterval.Hour * 1
                ),
                description: "breakfast description",
                isCompleted: false
            ),
            Task(
                title: "AI course",
                dateInterval: DateInterval(
                    start: makeDate(hour: 10, minute: 30),
                    duration: TimeInterval.Hour * 1),
                description: "ai course description",
                isCompleted: false
            ),
            Task(
                title: "Math course",
                dateInterval: DateInterval(
                    start: makeDate(hour: 13, minute: 0),
                    duration: TimeInterval.Hour * 1.5),
                description: "math course description",
                isCompleted: true
            )
        ]
    }
}
