import Foundation
import SwiftUICore
import AVFoundation
import UserNotifications

@MainActor
final class HomeViewModel: ObservableObject {
    
    @Published var navigateToPunchingGame = false
    @Published var isTargetReached = false
    
    final let TAG = "HomeViewModel"
    private var alarmManger = AlarmManager()
    private var notificationManager = NotificationManager()
    
    func delegate() {
        UNUserNotificationCenter.current().delegate = notificationManager
        alarmManger.setupAudioSession()
    }
    
    func setupNotification(for alarmTime: Date) {
//        notificationManager.scheduleNotification(for: alarmTime)
    }
    
    func setupAlarmSound(for setupTime: Date, at alarmTime: Date) {
        let now = Date()
        var finalAlarmTime = alarmTime
        if alarmTime <= now {
            finalAlarmTime = Calendar.current.date(byAdding: .day, value: 1, to: alarmTime)!
        }
        
        let whiteNoiseDelay = setupTime.timeIntervalSinceNow
        if whiteNoiseDelay > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + whiteNoiseDelay) {
                self.alarmManger.playWhiteNoise()
                print("White noise play")
            }
        } else {
            alarmManger.playWhiteNoise()
            print("White noise play")
        }
        
        let alarmDelay = finalAlarmTime.timeIntervalSinceNow
        if alarmDelay > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + alarmDelay) {
                self.alarmManger.stopWhiteNoise()
                self.alarmManger.playAlarmSound()
                print("Alarm noise play")
            }
        }
    }
    
    func stopAlarmSound() {
        alarmManger.stopAlarmSound()
        print("Alarm stopped")
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


/*
 
 if Date.now < setupTime {
 if let delay = setupTime.timeIntervalSinceNow
 }
 
 alarmManger.playWhiteNoise()
 
 let delay = alarmTime.timeIntervalSinceNow
 guard delay > 0 else {
 alarmManger.stopWhiteNoise()
 alarmManger.playAlarmSound()
 return
 }
 
 DispatchQueue.main.asyncAfter(deadline: alarmTime) {
 self.alarmManger.stopWhiteNoise()
 self.alarmManger.playAlarmSound()
 }
 
 
 */
