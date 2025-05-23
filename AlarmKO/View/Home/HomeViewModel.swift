import Foundation
import AVFoundation
import UserNotifications

@MainActor
final class HomeViewModel: ObservableObject {
    
    @Published var _alarmIsSet = false
    
    final let TAG = "HomeViewModel"
    
    let notificationManager: NotificationManager
    let alarmManager: AlarmManager
    
    init(notificationManager: NotificationManager, alarmManager: AlarmManager) {
        self.notificationManager = notificationManager
        self.alarmManager = alarmManager
    }
    
    func requestNotificationPermission() async {
        let center = UNUserNotificationCenter.current()
        
        do {
            try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            print("\(TAG): Request notification failed")
        }
    }
    
    func setupAudioSesstion() {
        alarmManager.setupAudioSession()
    }
    func scheduleAlarm(forTime alarmTime: Date) {
        alarmManager.changeIsAlarmPlayingToTrue(value: true)
        alarmManager.scheduleAlarms(at: alarmTime) {
            print("Alarm triggered from view model")
        }
        
        notificationManager.scheduleAlarmNotification(at: alarmTime)
        
        _alarmIsSet = true
        print("\(TAG): 10 alarm notifications scheduled.")
    }
    
    func cancelScheduleAlarm() {
        alarmManager.changeIsAlarmPlayingToTrue(value: false)
        alarmManager.cancelAlarms()
        alarmManager.stopAlarmEffects()
        notificationManager.cancelAllNotifications()
        
        print("\(TAG): Canceled scheduled alarm.")
    }
    
}
