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
    
    static var Minute: TimeInterval {
        return 60
    }
    
    static var Hour: TimeInterval {
        return 60 * Minute
    }
    
    static var Day: TimeInterval {
        return 24 * Hour
    }
}

extension TimeInterval {
    
    // MARK: - Representations
    
    var durationRepr: String {
        if self == 0 {
            return "0m"
        }
        
        let hours = Int(self) / Int(TimeInterval.Hour)
        let minutes = Int(self) % Int(TimeInterval.Hour) / Int(TimeInterval.Minute)
        
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
