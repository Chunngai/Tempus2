//
//  TimeIntervalExt.swift
//  Tempus2
//
//  Created by Sola on 2021/9/1.
//  Copyright © 2021 Sola. All rights reserved.
//

import Foundation

extension TimeInterval {
    
    // MARK: - Seconds of Time Units
    
    static var secondsOfOneMinute: TimeInterval {
        return 60
    }
    
    static var secondsOfOneHour: TimeInterval {
        return 60 * secondsOfOneMinute
    }
    
    static var secondsOfOneDay: TimeInterval {
        return 24 * secondsOfOneHour
    }
}

extension TimeInterval {
    
    // MARK: - Representations
    
    var durationRepr: String {
        if self == 0 {
            return "0m"
        }
        
        let hours = Int(self) / Int(TimeInterval.secondsOfOneHour)
        let minutes = Int(self) % Int(TimeInterval.secondsOfOneHour) / Int(TimeInterval.secondsOfOneMinute)
        
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
