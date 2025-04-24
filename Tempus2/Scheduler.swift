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

func makeNotificationRequest(
    title: String,
    body: String,
    categoryIdentifier: String,
    requestIdentifier: String,
    triggerDate: Date
) -> UNNotificationRequest {
    
    let content = UNMutableNotificationContent()
    content.title = title
    content.body = body
    content.categoryIdentifier = categoryIdentifier
    
    // Sets up trigger date.
    let trigger = UNCalendarNotificationTrigger(
        dateMatching: triggerDate.components(),
        repeats: false
    )
    
    // Creates request.
    let request = UNNotificationRequest(
        identifier: requestIdentifier,
        content: content,
        trigger: trigger
    )
    return request
}

// https://stackoverflow.com/questions/52009454/how-do-i-send-local-notifications-at-a-specific-time-in-swift
func prepareForNotifications() {
    
    print("prepareForNotifications")
    
    // Removes old notifications.
    removeAllNotifications()
    
    for task in Task.load().normalTasksOfToday {
        
        if task.isCompleted {
            continue
        }
        
        var categoryIdentifier = "eventNotification"
        if task.hasAlarm {
            categoryIdentifier = "eventAlarmNotification"
        }
        
        notificationCenter.add(makeNotificationRequest(
            title: "Upcoming Event",
            body: "\(task.titleRepresentation) · \(task.timeAndDurationRepresentation)",
            categoryIdentifier: categoryIdentifier,
            requestIdentifier: "\(task.identifier):willStart",
            triggerDate: task.dateInterval.start - 10 * TimeInterval.Minute
        ))
        
        notificationCenter.add(makeNotificationRequest(
            title: "Current Event",
            body: "\(task.titleRepresentation) · \(task.timeAndDurationRepresentation)",
            categoryIdentifier: categoryIdentifier,
            requestIdentifier: "\(task.identifier):didStart",
            triggerDate: task.dateInterval.start
        ))
        
        if task.hasAlarm {
            BackgroundVibrationManager.shared.createVibration(
                at: task.dateInterval.start, 
                identifier: "\(task.title)-\(task.dateInterval.start.dateAndTimeRepresentation())-\(task.identifier)"
            )
        }
        
        if task.type == .event {
            notificationCenter.add(makeNotificationRequest(
                title: "Event Ended",
                body: task.titleRepresentation,
                categoryIdentifier: categoryIdentifier,
                requestIdentifier: "\(task.identifier):didEnd",
                triggerDate: task.dateInterval.end
            ))
        }
        
    }
    
    printAllNotifications()
}

func printAllNotifications() {
    // https://stackoverflow.com/questions/40270598/ios-10-how-to-view-a-list-of-pending-notifications-using-unusernotificationcente
    notificationCenter.getPendingNotificationRequests(completionHandler: { requests in
        for (i, request) in requests.enumerated() {
            let requestDate = {
                guard let trigger = request.trigger as? UNCalendarNotificationTrigger else {
                    return ""
                }
                return trigger.nextTriggerDate()?.dateAndTimeRepresentation() ?? ""
            }()
            print(
                "Notification \(i+1):\n"
                + "- [title] \(request.content.title)\n"
                + "- [body] \(request.content.body)\n"
                + "- [date] \(requestDate)\n"
                + "- [id] \(request.content.categoryIdentifier)"
            )
        }
    })
}

func removeAllNotifications() {
    
    print("removeAllNotifications")
    
    // https://stackoverflow.com/questions/40562912/how-to-cancel-usernotifications
    notificationCenter.removeAllPendingNotificationRequests()
    notificationCenter.removeAllDeliveredNotifications()
    
    BackgroundVibrationManager.shared.stopAllVibrations()
}
