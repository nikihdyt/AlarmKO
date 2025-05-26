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
    
    let notificationCenter = UNUserNotificationCenter.current()
    
    @Published var navigateToGameScreen = false
    @Published var isGranted = false
    
    override init() {
        super.init()
        notificationCenter.delegate = self
    }
    
    func requestAuthorization() async throws {
        try await notificationCenter.requestAuthorization(options: [.sound, .badge, .alert])
        await getCurrentSettings()
    }
    
    func getCurrentSettings() async {
        let currentSettings = await notificationCenter.notificationSettings()
        isGranted = (currentSettings.authorizationStatus == .authorized)
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
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        cancelScheduleAlarm()
        
        completionHandler([.badge, .banner, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        UserDefaults.standard.set(true, forKey: "isNavigateToGame")
        cancelScheduleAlarm()
        
        completionHandler()
        
    }
    
    
    func scheduleNotification(forTime alarmTime: Date) {
        
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
            
            UNUserNotificationCenter.current().add(request)
        }
        
        print("\(TAG): 10 alarm notifications scheduled.")
    }
    
    func cancelScheduleAlarm() {
        
        let ids = (0..<10).map {
            "alarm_\($0)"
        }
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)

        print("\(TAG): Canceled scheduled alarm.")
    }
}
