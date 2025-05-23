import Foundation
import AVFoundation
import UserNotifications

@MainActor
final class GameViewModel: ObservableObject {
    let notificationManager: NotificationManager
    let alarmManager: AlarmManager
    
    init(notificationManager: NotificationManager, alarmManager: AlarmManager) {
        self.notificationManager = notificationManager
        self.alarmManager = alarmManager
    }
    
    func stopAlarm() {
        alarmManager.changeIsAlarmPlayingToTrue(value: false)
        alarmManager.cancelAlarms()
        alarmManager.stopAlarmEffects() // unused i guess
        notificationManager.cancelAllNotifications()
    }
}
