//
//  AlarmManager.swift
//  AlarmKO
//
//  Created by Niki Hidayati on 22/05/25.
//


import UserNotifications
import AVFoundation

class AlarmManager: NSObject, ObservableObject {
    static let shared = AlarmManager()
    
    private var audioPlayer: AVAudioPlayer?
    private let notificationCenter = UNUserNotificationCenter.current()
    @Published var isAlarmActive = false
    
    @Published var scheduledAlarms: [String] = []
    
    override init() {
        super.init()
        setupAudioSession()
        notificationCenter.delegate = self
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .default,
                options: [.mixWithOthers, .duckOthers]
            )
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session error: \(error)")
        }
    }
    
    // MARK: - Sound Control
    func playSound() {
        guard let url = Bundle.main.url(forResource: "alarm2", withExtension: "wav") else { return }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1
            audioPlayer?.play()
            isAlarmActive = true
        } catch {
            print("Playback error: \(error)")
        }
    }
    
    func stopSound() {
        audioPlayer?.stop()
    }
    
}

// MARK: - Notification Handling
extension AlarmManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        isAlarmActive = true
        print("alarm Manager -- userNotificationCenter")
        completionHandler([.banner, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        playSound()
        
        completionHandler()
    }
}
