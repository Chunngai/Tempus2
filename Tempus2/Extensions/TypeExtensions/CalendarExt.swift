//
//  CalendarExt.swift
//  Tempus2
//
//  Created by Sola on 2022/7/11.
//  Copyright © 2022 Sola. All rights reserved.
//

import Foundation

extension Calendar {
    
    func weekdaySymbolIndex(of date: Date) -> Int {
        return self.component(.weekday, from: date) - 1
    }
    
    func weekdaySymbol(of date: Date) -> String {
        return self.weekdaySymbols[self.weekdaySymbolIndex(of: date)]
    }
    
}
