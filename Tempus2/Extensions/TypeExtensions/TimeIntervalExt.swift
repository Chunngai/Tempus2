//
//  TimeIntervalExt.swift
//  Tempus2
//
//  Created by Sola on 2021/9/1.
//  Copyright © 2021 Sola. All rights reserved.
//

import Foundation

extension TimeInterval {
    static var secsOfOneMin: Double {
        return 60
    }
    
    static var secsOfOneHour: Double {
        return 60 * secsOfOneMin
    }
}
