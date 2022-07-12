//
//  Scheduler.swift
//  Tempus2
//
//  Created by Sola on 2022/6/7.
//  Copyright © 2022 Sola. All rights reserved.
//

import Foundation
import UIKit

var notificationCenter = UNUserNotificationCenter.current()

func makeNotificationRequest(title: String, body: String, identifier: String, triggerDate: Date, shouldVibrate: Bool = false) -> UNNotificationRequest {
    let content = UNMutableNotificationContent()
    content.title = title
    content.body = body
    content.categoryIdentifier = "eventNotification"
    if shouldVibrate {
        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "silence.aif"))
    }
    
    // Sets up trigger date.
    let triggerDate = triggerDate
    var triggerDateComponents = DateComponents()
    triggerDateComponents.year = triggerDate.get(.year)
    triggerDateComponents.month = triggerDate.get(.month)
    triggerDateComponents.day = triggerDate.get(.day)
    triggerDateComponents.hour = triggerDate.get(.hour)
    triggerDateComponents.minute = triggerDate.get(.minute)
    triggerDateComponents.second = 0
    let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDateComponents, repeats: false)
    
    // Creates request.
    let request = UNNotificationRequest(
        identifier: identifier,
        content: content,
        trigger: trigger
    )
    return request
}

// https://stackoverflow.com/questions/52009454/how-do-i-send-local-notifications-at-a-specific-time-in-swift
func prepareForNotifications() {
    // Removes old notifications.
    removeAllNotifications()
    
    for task in Task.load().normalTasksOfToday {
        if task.isCompleted {
            continue
        }
        
        if !task.hasAlarm {
            notificationCenter.add(makeNotificationRequest(
                title: task.titleRepresentation,
                body: "Starts at: \(task.dateInterval.start.timeRepresentation())",
                identifier: "\(task.identifier):start",
                triggerDate: task.dateInterval.start - 10 * TimeInterval.Minute
            ))
            if task.type == .event {
                notificationCenter.add(makeNotificationRequest(
                    title: task.titleRepresentation,
                    body: "Finished",
                    identifier: "\(task.identifier):finish",
                    triggerDate: task.dateInterval.end
                ))
            }
        } else {
            // Reminds multiple times.
            
            for interval in [0, 2, 4, 6, 8, 10] {
                notificationCenter.add(makeNotificationRequest(
                    title: task.titleRepresentation,
                    body: "Starts at: \(task.dateInterval.start.timeRepresentation())",
                    identifier: "\(task.identifier):alarm:\(interval)",
                    triggerDate: task.dateInterval.start + TimeInterval.Minute * Double(interval),
                    shouldVibrate: false
                ))
                
//                for i in 1...30 {
//                    // https://stackoverflow.com/questions/42431171/local-notifications-make-sound-but-do-not-display-swift
//                    notificationCenter.add(makeNotificationRequest(
//                        title: "",
//                        body: "",
//                        identifier: "\(task.identifier):alarm:\(interval):\(i)",
//                        triggerDate: task.dateInterval.start + TimeInterval.Minute * Double(interval + Double(i) * 2,
//                        shouldVibrate: true
//                    ))
//                }
            }
        }
    }
    
    printAllNotifications()
}

func printAllNotifications() {
    // https://stackoverflow.com/questions/40270598/ios-10-how-to-view-a-list-of-pending-notifications-using-unusernotificationcente
    notificationCenter.getPendingNotificationRequests(completionHandler: { requests in
        for request in requests {
            print(
                "[title] \(request.content.title); "
                    + "[body] \(request.content.body); "
                    + "[date] \((request.trigger as? UNCalendarNotificationTrigger)!.dateComponents)"
            )
        }
    })
}

func removeAllNotifications() {
    // https://stackoverflow.com/questions/40562912/how-to-cancel-usernotifications
    notificationCenter.removeAllPendingNotificationRequests()
    notificationCenter.removeAllDeliveredNotifications()
}
