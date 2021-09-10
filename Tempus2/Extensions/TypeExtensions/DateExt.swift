//
//  DateExtensions.swift
//  Tempus2
//
//  Created by Sola on 2021/8/30.
//  Copyright © 2021 Sola. All rights reserved.
//

import Foundation

extension Date {
    // https://stackoverflow.com/questions/38248941/how-to-get-time-hour-minute-second-in-swift-3-using-nsdate
    func getComponent(_ component: Calendar.Component) -> Int {
        return Calendar
            .current
            .component(component, from: self)
    }
    
    func getComponents(_ components: [Calendar.Component]) -> [Int] {
        return components.compactMap { (component) -> Int in
            getComponent(component)
        }
    }
}
 
extension Date {
    
    private var defaultDateFormat: String {
        "EEEE, MMM d"
    }
    
    private var defaultTimeFormat: String {
        return "HH:mm"
    }
    
    private var defaultMonthFormat: String {
        return "MMMM"
    }
    
    private func makeRepr(with format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = TimeZone(secondsFromGMT: TimeZone.current.secondsFromGMT())
        return dateFormatter.string(from: self)
    }
    
    func dateRepr(ofFormat format: String = "") -> String {
        let dateFormat = format.isEmpty ? defaultDateFormat : format
        return makeRepr(with: dateFormat)
    }
    
    func timeRepr(ofFormat format: String = "") -> String {
        let timeFormat = format.isEmpty ? defaultTimeFormat : format
        return makeRepr(with: timeFormat)
    }
    
    func monthRepr(ofFormat format: String = "") -> String {
        let monthFormat = format.isEmpty ? defaultMonthFormat : format
        return makeRepr(with: monthFormat)
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
    var yesterday: Date {
        self - TimeInterval.secsOfOneDay
    }
    
    var tomorrow: Date {
        self + TimeInterval.secsOfOneDay
    }
}
