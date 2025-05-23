import Foundation
import SwiftUICore
import AVFoundation
import UserNotifications

@MainActor
final class HomeViewModel: ObservableObject {
    
    @Published var _alarmIsSet = false
    @Published var navigateToPunchingGame = false
    
    final let TAG = "HomeViewModel"
    private var alarmManger = AlarmManager()
    
    func delegate() {
        UNUserNotificationCenter.current().delegate = notificationManager
        alarmManger.setupAudioSession()
    }
    
    func setupNotification(for alarmTime: Date) {
        notificationManager.scheduleNotification(forTime: alarmTime)
    }
    
    func setupAlarmSound(for alarmTime: Date) {
        
        alarmManger.playWhiteNoise()
        
        let delay = alarmTime.timeIntervalSinceNow
        guard delay > 0 else {
            alarmManger.stopWhiteNoise()
            alarmManger.playAlarmSound()
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.alarmManger.stopWhiteNoise()
            self.alarmManger.playAlarmSound()
        }
    }
    
    func stopAlarmSound() {
        alarmManger.stopAlarmSound()
    }
    
    func requestNotificationPermission() async {
        let center = UNUserNotificationCenter.current()
        
        do {
            try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            print("\(TAG): Request notification failed")
        }
    }
}
