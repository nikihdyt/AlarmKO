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
    
    @AppStorage("navState") private var navState: String = GameNavigationState.home.rawValue
    @AppStorage("notificationPermissionGranted") var isGranted = false
    
    // Configuration constants
    private let alarmCategoryIdentifier = "ALARM_RINGING"
    private let bedtimeCategoryIdentifier = "BEDTIME_REMINDER"
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
    
    // MARK: Schedule Notification
    func scheduleNotification(for alarmViewModel: AlarmViewModel) async {
        
        print("Notification permission: \(isGranted)")
        
        guard isGranted else {
            print("\(TAG)Notification permission not granted")
            return
        }
        
        // Cancel existing notifications first
        cancelScheduleAlarm()
        
        guard alarmViewModel.isActive else {
            print("\(TAG)Alarm is not active")
            return
        }
        
        let selectedDays = alarmViewModel.selectedDays
        guard !selectedDays.isEmpty else {
            print("\(TAG)No days selected for alarm")
            return
        }
        
        // Schedule for each selected day
        for day in selectedDays {
            await scheduleBedtimeReminder(for: day, alarmViewModel: alarmViewModel)
            await scheduleAlarmForWeekday(day, alarmViewModel: alarmViewModel)
        }
        
        print("\(TAG)Scheduled alarms for \(selectedDays.count) day(s)")
        print("\(TAG)Bedtime reminders and alarm notifications scheduled.")
    }
    
    private func scheduleBedtimeReminder(for weekday: AlarmRepeat, alarmViewModel: AlarmViewModel) async {
        guard let hour = alarmViewModel.sleepTime.hour,
              let minute = alarmViewModel.sleepTime.minute else {
            print("\(TAG)Invalid sleep time")
            return
        }
        
        let weekdayNumber = weekdayToCalendarWeekday(weekday)
        
        let content = UNMutableNotificationContent()
        content.title = "🌙 Bedtime Reminder"
        content.body = getBedtimeMessage(label: alarmViewModel.label)
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = bedtimeCategoryIdentifier
        content.userInfo = [
            "isBedtime": true,
            "alarmLabel": alarmViewModel.label
        ]
        
        // Create trigger with weekday and time
        var triggerDate = DateComponents()
        triggerDate.weekday = weekdayNumber
        triggerDate.hour = hour
        triggerDate.minute = minute
        triggerDate.second = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: true)
        let identifier = "bedtime_\(weekday.rawValue.lowercased())"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        do {
            try await notificationCenter.add(request)
        } catch {
            print("\(TAG)Failed to schedule bedtime notification: \(error)")
        }
    }
    
    private func scheduleAlarmForWeekday(_ weekday: AlarmRepeat, alarmViewModel: AlarmViewModel) async {
        guard let hour = alarmViewModel.wakeUpTime.hour,
              let minute = alarmViewModel.wakeUpTime.minute else {
            print("\(TAG)Invalid wake up time")
            return
        }
        
        let weekdayNumber = weekdayToCalendarWeekday(weekday)
        
        // Schedule multiple notifications for persistence
        for i in 0..<maxNotifications {
            let content = UNMutableNotificationContent()
            content.title = alarmViewModel.label.isEmpty ? "⏰ Alarm" : "⏰ \(alarmViewModel.label)"
            content.body = getAlarmMessage(for: i)
            content.sound = getNotificationSound(for: alarmViewModel.alarmSound)
            content.categoryIdentifier = alarmCategoryIdentifier
            content.userInfo = [
                "isAlarm": true,
                "game": alarmViewModel.alarmGame.rawValue,
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
    
    func cancelAllAlarmNotifications() {
        notificationCenter.getPendingNotificationRequests { pendingRequests in
            let alarmIdentifiers = pendingRequests
                .filter { $0.identifier.hasPrefix("alarm_") || $0.identifier.hasPrefix("bedtime_") }
                .map { $0.identifier }
            
            if !alarmIdentifiers.isEmpty {
                self.notificationCenter.removePendingNotificationRequests(withIdentifiers: alarmIdentifiers)
                print("\(self.TAG)Canceled \(alarmIdentifiers.count) pending notifications (alarms + bedtime)")
            }
        }
        
        print("\(TAG)All alarm notifications cancellation requested")
    }
    
    func cancelScheduleAlarm() {
        notificationCenter.getPendingNotificationRequests { pendingRequests in
            let pendingAlarmIdentifiers = pendingRequests
                .filter { $0.identifier.hasPrefix("alarm_") || $0.identifier.hasPrefix("bedtime_") }
                .map { $0.identifier }
            
            if !pendingAlarmIdentifiers.isEmpty {
                self.notificationCenter.removePendingNotificationRequests(withIdentifiers: pendingAlarmIdentifiers)
                print("\(self.TAG)Canceled \(pendingAlarmIdentifiers.count) pending notifications (alarms + bedtime)")
            }
        }
        
        print("\(TAG)Alarm cancellation requested")
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
    
    private func getBedtimeMessage(label: String) -> String {
        let baseMessages = [
            "Time to wind down and get ready for bed! 😴",
            "It's bedtime! Sweet dreams! 🌙",
            "Time to put your devices away and relax! 📱💤",
            "Bedtime reminder: Get some good rest tonight! ✨",
            "Time to sleep! Tomorrow's a new day! 🌟"
        ]
        
        let randomMessage = baseMessages.randomElement() ?? baseMessages[0]
        
        if !label.isEmpty {
            return "\(randomMessage) Don't forget your \(label) alarm is set for tomorrow!"
        } else {
            return randomMessage
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
    }
    
    // MARK: - Debug Methods
    func printScheduledNotifications() async {
        let pendingRequests = await notificationCenter.pendingNotificationRequests()
        let alarmRequests = pendingRequests.filter { $0.identifier.hasPrefix("alarm_") }
        let bedtimeRequests = pendingRequests.filter { $0.identifier.hasPrefix("bedtime_") }
        
        print("\(TAG)=== SCHEDULED NOTIFICATIONS DEBUG ===")
        print("Total notifications pending: \(pendingRequests.count)")
        print("Total alarm notifications: \(alarmRequests.count)")
        print("Total bedtime notifications: \(bedtimeRequests.count)")
        
        let now = Date()
        let calendar = Calendar.current
        let currentWeekday = calendar.component(.weekday, from: now)
        let currentHour = calendar.component(.hour, from: now)
        let currentMinute = calendar.component(.minute, from: now)
        
        print("\nCurrent time info:")
        print("  Date/Time: \(now)")
        print("  Weekday: \(currentWeekday) (\(weekdayToString(currentWeekday)))")
        print("  Hour: \(currentHour), Minute: \(currentMinute)")
        
        print("\n--- BEDTIME REMINDERS ---")
        if bedtimeRequests.isEmpty {
            print("❌ NO BEDTIME NOTIFICATIONS SCHEDULED!")
        }
        
        for request in bedtimeRequests.sorted(by: { $0.identifier < $1.identifier }) {
            if let trigger = request.trigger as? UNCalendarNotificationTrigger {
                let triggerWeekday = trigger.dateComponents.weekday ?? 0
                let triggerHour = trigger.dateComponents.hour ?? 0
                let triggerMinute = trigger.dateComponents.minute ?? 0
                
                print("✅ ID: \(request.identifier)")
                print("   Title: \(request.content.title)")
                print("   Body: \(request.content.body)")
                print("   Weekday: \(triggerWeekday) (\(weekdayToString(triggerWeekday)))")
                print("   Time: \(triggerHour):\(String(format: "%02d", triggerMinute))")
                print("   Repeats: \(trigger.repeats)")
                
                // Check if this should fire today
                if triggerWeekday == currentWeekday {
                    if (triggerHour > currentHour) || (triggerHour == currentHour && triggerMinute > currentMinute) {
                        print("   🟢 SHOULD FIRE TODAY")
                    } else {
                        print("   🔴 ALREADY PASSED TODAY")
                    }
                } else {
                    print("   🟡 DIFFERENT DAY")
                }
                print("---")
            } else {
                print("❌ Invalid trigger type for \(request.identifier)")
            }
        }
        
        print("\n--- ALARM NOTIFICATIONS ---")
        let uniqueAlarms = Dictionary(grouping: alarmRequests) { request in
            String(request.identifier.prefix(while: { $0 != "_" || !$0.isNumber }))
        }
        
        for (baseId, requests) in uniqueAlarms.sorted(by: { $0.key < $1.key }) {
            if let firstRequest = requests.first,
               let trigger = firstRequest.trigger as? UNCalendarNotificationTrigger {
                let triggerWeekday = trigger.dateComponents.weekday ?? 0
                let triggerHour = trigger.dateComponents.hour ?? 0
                let triggerMinute = trigger.dateComponents.minute ?? 0
                
                print("✅ \(baseId) (x\(requests.count) notifications)")
                print("   Weekday: \(triggerWeekday) (\(weekdayToString(triggerWeekday)))")
                print("   Time: \(triggerHour):\(String(format: "%02d", triggerMinute))")
                print("---")
            }
        }
        print("=== END NOTIFICATIONS DEBUG ===")
    }
    
    private func weekdayToString(_ weekday: Int) -> String {
        switch weekday {
        case 1: return "Sunday"
        case 2: return "Monday"
        case 3: return "Tuesday"
        case 4: return "Wednesday"
        case 5: return "Thursday"
        case 6: return "Friday"
        case 7: return "Saturday"
        default: return "Unknown"
        }
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        // Handle different types of notifications
        if notification.request.content.userInfo["isAlarm"] as? Bool == true {
            // For alarm notifications, cancel all and navigate to game
            cancelAllAlarmNotifications()
            print("cancel alarm notifs from UNCenter willPresent")
            completionHandler([.banner, .sound, .badge])
        } else if notification.request.content.userInfo["isBedtime"] as? Bool == true {
            // For bedtime notifications, just show the notification
            print("Bedtime reminder shown")
            completionHandler([.banner, .sound, .badge])
        } else {
            completionHandler([])
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        // Handle different types of notifications
        if response.notification.request.content.userInfo["isAlarm"] as? Bool == true {
            // For alarm notifications, cancel all and navigate to game
            cancelAllAlarmNotifications()
            print("cancel alarm notifs from UNCenter didReceive")
            
            navState = GameNavigationState.game.rawValue
            print("navState set to: {\(navState)} from notif center didReceive")
            
        } else if response.notification.request.content.userInfo["isBedtime"] as? Bool == true {
            // For bedtime notifications, just acknowledge
            print("Bedtime reminder acknowledged")
        }
        completionHandler()
    }
}
