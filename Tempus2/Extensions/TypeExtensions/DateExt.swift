//
//  DateExtensions.swift
//  Tempus2
//
//  Created by Sola on 2021/8/30.
//  Copyright © 2021 Sola. All rights reserved.
//

import Foundation

extension Date {
    
    // MARK: - Getting Components
    
    // https://stackoverflow.com/questions/38248941/how-to-get-time-hour-minute-second-in-swift-3-using-nsdate
    func get(_ component: Calendar.Component) -> Int {
        return Calendar
            .current
            .component(
                component,
                from: self
            )
    }
    
    func get(_ components: [Calendar.Component]) -> [Int] {
        return components.compactMap { (component) -> Int in
            get(component)
        }
    }
    
    func components(of components: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute, .second]) -> DateComponents {
        return Calendar.current.dateComponents(
            components,
            from: self
        )
    }
    
    func setSecondToZero() -> Date {
        var components = self.components()
        components.second = 0
        return Calendar.current.date(from: components) ?? self
    }
    
}
 
extension Date {
    
    // MARK: - Representations
    
    private var defaultDateFormat: String {
        "EE, MMM d"
    }
    
    private var defaultTimeFormat: String {
        return "HH:mm"
    }
    
    private var defaultDateAndTimeFormat: String {
        return defaultDateFormat + " " + defaultTimeFormat
    }
    
    private var defaultMonthFormat: String {
        return "MMMM, yyyy"
    }
    
    private func makeRepresentation(with format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = TimeZone(secondsFromGMT: TimeZone.current.secondsFromGMT())
        return dateFormatter.string(from: self)
    }
    
    func dateRepresentation(ofFormat format: String = "") -> String {
        let dateFormat = format.isEmpty
            ? defaultDateFormat
            : format
        return makeRepresentation(with: dateFormat)
    }
    
    func timeRepresentation(ofFormat format: String = "") -> String {
        let timeFormat = format.isEmpty
            ? defaultTimeFormat
            : format
        return makeRepresentation(with: timeFormat)
    }
    
    func dateAndTimeRepresentation(ofFormat format: String = "") -> String {
        let dateAndTimeFormat = format.isEmpty
            ?  defaultDateAndTimeFormat
            : format
        return makeRepresentation(with: dateAndTimeFormat)
    }
    
    func monthRepresentation(ofFormat format: String = "") -> String {
        let monthFormat = format.isEmpty
            ? defaultMonthFormat
            : format
        return makeRepresentation(with: monthFormat)
    }
}

extension Date {
        
    // https://stackoverflow.com/questions/5979462/problem-combining-a-date-and-a-time-into-a-single-nsdate
    static func combine(date: Date, with time: Date) -> Date {
        let calendar = Calendar.current

        let dateComponents = calendar.dateComponents(
            [.year, .month, .day],
            from: date
        )
        let timeComponents = calendar.dateComponents(
            [.hour, .minute, .second],
            from: time
        )

        var components = DateComponents()
        components.year = dateComponents.year
        components.month = dateComponents.month
        components.day = dateComponents.day
        components.hour = timeComponents.hour
        components.minute = timeComponents.minute
        components.second = timeComponents.second
        return calendar.date(from: components)!
    }
}

extension Date {
    
    // MARK: - Days
    
    var yesterday: Date {
        self - TimeInterval.Day
    }
    
    var tomorrow: Date {
        self + TimeInterval.Day
    }
}
