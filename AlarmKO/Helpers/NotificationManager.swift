//
//  NotificationManager.swift
//  AlarmKO
//
//  Created by Ziqa on 22/05/25.
//

import Foundation
import UserNotifications

class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate{
    
    @Published var navigateToGame: Bool = false
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        navigateToGame.toggle()
        
        completionHandler([.badge, .banner, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
            
        navigateToGame.toggle()
        
        completionHandler()
    }
    
    func scheduleAlarmNotification(at date: Date, count: Int = 10) {
        for i in 0..<count {
            let fireTime = Calendar.current.date(byAdding: .second, value: i * 9, to: date)!

            let content = UNMutableNotificationContent()
            content.title = "⏰ Alarm"
            content.body = "Wake up \(i)!"
            content.sound = .default
            content.categoryIdentifier = "alarmCategory"

            let triggerDate = Calendar.current.dateComponents([.hour, .minute, .second], from: fireTime)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

            let request = UNNotificationRequest(identifier: "alarm_\(i)", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
        
        print("🔔 \(count) alarm notifications scheduled.")
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        print("All scheduled notifications are canceled.")
    }

}
