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
}
 
extension Date {
    
    private var dateFormat: String {
        "EEEE, MMM d"
    }
    
    private var timeFormat: String {
        return "HH:mm"
    }
    
    private func makeRepr(with format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = TimeZone(secondsFromGMT: TimeZone.current.secondsFromGMT())
        return dateFormatter.string(from: self)
    }
    
    var dateRepr: String {
        makeRepr(with: dateFormat)
    }
    
    var timeRepr: String {
        makeRepr(with: timeFormat)
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
