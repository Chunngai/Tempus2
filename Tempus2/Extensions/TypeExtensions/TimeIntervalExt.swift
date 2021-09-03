//
//  TimeIntervalExt.swift
//  Tempus2
//
//  Created by Sola on 2021/9/1.
//  Copyright © 2021 Sola. All rights reserved.
//

import Foundation

extension TimeInterval {
    static var secsOfOneMinute: TimeInterval {
        return 60
    }
    
    static var secsOfOneHour: TimeInterval {
        return 60 * secsOfOneMinute
    }
}

extension TimeInterval {
    var durationRepr: String {
        let hours = Int(self) / Int(TimeInterval.secsOfOneHour)
        let minutes = Int(self) % Int(TimeInterval.secsOfOneHour) / Int(TimeInterval.secsOfOneMinute)
        
        var repr = ""
        if hours != 0 {
            repr += "\(hours)h"
        }
        if minutes != 0 {
            repr += " \(minutes)m"
        }
        return repr.trimmingWhitespacesAndNewlines()
    }
}
