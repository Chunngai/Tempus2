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
    
    static var secsOfOneDay: TimeInterval {
        return 24 * secsOfOneHour
    }
}

extension TimeInterval {
    var durationRepr: String {
        if self == 0 {
            return "0m"
        }
        
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
