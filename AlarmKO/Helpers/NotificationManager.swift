//
//  NotificationManager.swift
//  AlarmKO
//
//  Created by Ziqa on 22/05/25.
//

import SwiftUI
import UserNotifications

@MainActor
class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    
    private final let TAG: String = "Notification Manager: "
    private let notificationCenter = UNUserNotificationCenter.current()
    
    @Published var navigateToGameScreen = false
    @AppStorage("notificationPermissionGranted") var isGranted = false
    
    // Configuration constants
    private let alarmCategoryIdentifier = "ALARM_RINGING"
    private let snoozeActionIdentifier = "SNOOZE_ACTION"
    private let dismissActionIdentifier = "DISMISS_ACTION"
    private let maxNotifications = 10
    private let notificationInterval = 5 // seconds
    
    override init() {
        super.init()
        notificationCenter.delegate = self
    }
    
    // MARK: Authorization
    func requestAuthorization() async throws {
        try await notificationCenter.requestAuthorization(options: [.sound, .badge, .alert])
        await getCurrentSettings()
    }
    
    func getCurrentSettings() async {
        let currentSettings = await notificationCenter.notificationSettings()
        isGranted = (currentSettings.authorizationStatus == .authorized)
        
        print("\(TAG)Authorization status: \(isGranted)")
    }
    
    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(url) {
                Task {
                    await UIApplication.shared.open(url)
                }
            }
        }
    }
    
    func scheduleNotification(for alarmSettings: AlarmSettings) async {
        
        print("Notification permission: \(isGranted)")
        
        guard isGranted else {
            print("\(TAG)Notification permission not granted")
            return
        }
        
        // Cancel existing notifications first
        await cancelScheduleAlarm()
        
        guard alarmSettings.isActive else {
            print("\(TAG)Alarm is not active")
            return
        }
        
        let selectedDays = alarmSettings.selectedDays
        guard !selectedDays.isEmpty else {
            print("\(TAG)No days selected for alarm")
            return
        }
        
        // Schedule for each selected day
        for day in selectedDays {
            await scheduleAlarmForWeekday(day, alarmSettings: alarmSettings)
        }
        
        print("\(TAG)Scheduled alarms for \(selectedDays.count) day(s)")
        
               
        print("\(TAG): 10 alarm notifications scheduled.")
    }
    
    private func scheduleAlarmForWeekday(_ weekday: AlarmRepeat, alarmSettings: AlarmSettings) async {
        guard let hour = alarmSettings.wakeUpTime.hour,
              let minute = alarmSettings.wakeUpTime.minute else {
            print("\(TAG)Invalid wake up time")
            return
        }
        
        let weekdayNumber = weekdayToCalendarWeekday(weekday)
        
        // Schedule multiple notifications for persistence
        for i in 0..<maxNotifications {
            let content = UNMutableNotificationContent()
            content.title = alarmSettings.label.isEmpty ? "⏰ Alarm" : "⏰ \(alarmSettings.label)"
            content.body = getAlarmMessage(for: i)
            content.sound = getNotificationSound(for: alarmSettings.alarmSound)
            content.categoryIdentifier = alarmCategoryIdentifier
            content.userInfo = [
                "isAlarm": true,
                "game": alarmSettings.alarmGame.rawValue,
                "notificationIndex": i
            ]
            
            // Create trigger with weekday and time
            var triggerDate = DateComponents()
            triggerDate.weekday = weekdayNumber
            triggerDate.hour = hour
            triggerDate.minute = minute
            triggerDate.second = i * notificationInterval
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: true)
            let identifier = "alarm_\(weekday.rawValue.lowercased())_\(i)"
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            do {
                try await notificationCenter.add(request)
            } catch {
                print("\(TAG)Failed to schedule notification: \(error)")
            }
        }
    }
    
    func cancelScheduleAlarm() async {
        let pendingRequests = await notificationCenter.pendingNotificationRequests()
        let alarmIdentifiers = pendingRequests
            .filter { $0.identifier.hasPrefix("alarm_") }
            .map { $0.identifier }
        
        notificationCenter.removePendingNotificationRequests(withIdentifiers: alarmIdentifiers)
        print("\(TAG)Canceled \(alarmIdentifiers.count) scheduled alarm notifications")
    }
    
    // MARK: - Helper Methods
    private func weekdayToCalendarWeekday(_ weekday: AlarmRepeat) -> Int {
        switch weekday {
        case .sunday: return 1
        case .monday: return 2
        case .tuesday: return 3
        case .wednesday: return 4
        case .thursday: return 5
        case .friday: return 6
        case .saturday: return 7
        }
    }
    
    private func getAlarmMessage(for index: Int) -> String {
        let messages = [
            "Time to wake up! 🌅",
            "Rise and shine! ☀️",
            "Good morning! Time to start your day! 💪",
            "Wake up! Your day awaits! 🚀",
            "Time to get up and conquer the day! 🏆",
            "Morning alarm! Let's go! ⚡",
            "Wake up call! Rise and grind! 💯",
            "Time's up! Start your amazing day! ✨",
            "Final wake up call! 🔔",
            "Last chance! Wake up now! ⏰"
        ]
        return messages[min(index, messages.count - 1)]
    }
    
    private func getNotificationSound(for sound: AlarmSound) -> UNNotificationSound {
        switch sound {
        case .beep:
            return UNNotificationSound.default
        case .alert:
            return UNNotificationSound.defaultCritical
        }
        
        // MARK: - Debug Methods
        func printScheduledNotifications() async {
            let pendingRequests = await notificationCenter.pendingNotificationRequests()
            let alarmRequests = pendingRequests.filter { $0.identifier.hasPrefix("alarm_") }
            
            print("\(TAG)=== SCHEDULED NOTIFICATIONS ===")
            print("Total alarm notifications: \(alarmRequests.count)")
            
            for request in alarmRequests.sorted(by: { $0.identifier < $1.identifier }) {
                if let trigger = request.trigger as? UNCalendarNotificationTrigger {
                    print("ID: \(request.identifier)")
                    print("  Title: \(request.content.title)")
                    print("  Weekday: \(trigger.dateComponents.weekday ?? 0)")
                    print("  Time: \(trigger.dateComponents.hour ?? 0):\(String(format: "%02d", trigger.dateComponents.minute ?? 0))")
                    print("  Repeats: \(trigger.repeats)")
                    print("---")
                }
            }
            print("=== END NOTIFICATIONS ===")
        }
        
        // MARK: - UNUserNotificationCenterDelegate
        func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
            
            // Show notification even when app is in foreground
            if notification.request.content.userInfo["isAlarm"] as? Bool == true {
                completionHandler([.banner, .sound, .badge])
            } else {
                completionHandler([])
            }
        }
        
        func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) async {
            
            let userInfo = response.notification.request.content.userInfo
            
            if userInfo["isAlarm"] as? Bool == true {
                switch response.actionIdentifier {
                case snoozeActionIdentifier:
                    await snoozeAlarm()
                    
                case dismissActionIdentifier:
                    await cancelScheduleAlarm()
                    
                case UNNotificationDefaultActionIdentifier:
                    // User tapped the notification
                    navigateToGameScreen = true
                    
                default:
                    break
                }
            }
            
            completionHandler()
        }
        
        func snoozeAlarm() async {
            // Schedule a single notification 5 minutes from now
            let content = UNMutableNotificationContent()
            content.title = "⏰ Snooze Alarm"
            content.body = "Time to wake up! (Snoozed)"
            content.sound = UNNotificationSound.default
            content.categoryIdentifier = alarmCategoryIdentifier
            content.userInfo = ["isAlarm": true]
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 300, repeats: false) // 5 minutes
            let request = UNNotificationRequest(identifier: "snooze_alarm", content: content, trigger: trigger)
            
            do {
                try await notificationCenter.add(request)
                print("\(TAG)Snooze alarm scheduled for 5 minutes")
            } catch {
                print("\(TAG)Failed to schedule snooze: \(error)")
            }
        }
        
        //    func cancelScheduleAlarm() {
        //        let ids = (0..<10).map {
        //            "alarm_\($0)"
        //        }
        //
        //        notificationCenter.removePendingNotificationRequests(withIdentifiers: ids)
        //        print("\(TAG): Canceled scheduled alarm.")
        //    }
    }
}


/*
 
 func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
 
 cancelScheduleAlarm()
 
 completionHandler([.badge, .banner, .sound])
 }
 
 func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
 
 UserDefaults.standard.set(true, forKey: "isNavigateToGame")
 cancelScheduleAlarm()
 
 completionHandler()
 
 }
 
 */


/*
 
 for i in 0..<10 {
     let fireTime = Calendar.current.date(byAdding: .second, value: i * 9, to: alarmTime)!
     let content = UNMutableNotificationContent()

     content.title = "⏰ Alarm"
     content.body = "Wake up \(i)!"
     content.sound = UNNotificationSound.default
     content.categoryIdentifier = "ALARM_RINGING"

     let triggerDate = Calendar.current.dateComponents([.hour, .minute, .second], from: fireTime)
     let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
     let request = UNNotificationRequest(identifier: "alarm_\(i)", content: content, trigger: trigger)

     notificationCenter.add(request)
 }
 
 */
