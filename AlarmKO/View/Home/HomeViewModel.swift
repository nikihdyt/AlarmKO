import Foundation
import AVFoundation
import UserNotifications

@MainActor
final class HomeViewModel: ObservableObject {
    
    @Published var _alarmIsSet = false
    @Published var _audioPlayer: AVAudioPlayer?
    @Published var _whiteNoisePlayer: AVAudioPlayer?
    
    final let TAG = "HomeViewModel"
    
    func setupAudioSession() {
        do {
            // Set the audio session to playback mode, which allows background audio
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Error setting up audio session: \(error.localizedDescription)")
        }
    }
    
    func playWhiteNoise() {
        guard let url = Bundle.main.url(forResource: "white_noise", withExtension: "mp3") else {
            print("White noise file not found")
            return
        }
        
        do {
            _whiteNoisePlayer = try AVAudioPlayer(contentsOf: url)
            _whiteNoisePlayer?.numberOfLoops = -1 // Loop indefinitely
            _whiteNoisePlayer?.prepareToPlay()
            _whiteNoisePlayer?.play()
        } catch {
            print("Error playing white noise: \(error.localizedDescription)")
        }
    }
    
    // Stop white noise sound
    func stopWhiteNoise() {
        _whiteNoisePlayer?.stop()
    }
    
    func playSound() {
        setupAudioSession()
        
        guard let url = Bundle.main.url(forResource: "alarm", withExtension: "wav") else {
            print("Sound file not found")
            return
        }
        
        do {
            _audioPlayer = try AVAudioPlayer(contentsOf: url)
            _audioPlayer?.prepareToPlay()
            _audioPlayer?.play()
        } catch {
            print("Error playing sound: \(error.localizedDescription)")
        }
    }
    
    func stopSound() {
        _audioPlayer?.stop()
    }
    
    
    func requestNotificationPermission() async {
        let center = UNUserNotificationCenter.current()
        
        do {
            try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            print("\(TAG): Request notification failed")
        }
    }
    
    func scheduleAlarm(forTime alarmTime: Date) {
        _ = UNNotificationSoundName("alarmNotification.caf")
        playWhiteNoise()
        
        for i in 0..<10 {
            let fireTime = Calendar.current.date(byAdding: .second, value: i * 9, to: alarmTime)!
            let content = UNMutableNotificationContent()
            
            content.title = "⏰ Alarm"
            content.body = "Wake up \(i)!"
            content.sound = UNNotificationSound.default
            content.categoryIdentifier = "alarmCategory"
            
            let triggerDate = Calendar.current.dateComponents([.hour, .minute, .second], from: fireTime)
            print()
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
            let request = UNNotificationRequest(identifier: "alarm_\(i)", content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request)
            
            let delay = fireTime.timeIntervalSinceNow
            if delay > 0 {
                print("here")
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    print("Scheduled to run at: \(Date().addingTimeInterval(delay))")
                    print("")
                    self.stopWhiteNoise()  // Stop white noise when alarm time arrives
                    self.playSound()  // Play the alarm sound
                    print("alarm played")
                }
            } else {
                // If the fireTime is in the past, stop white noise and play sound immediately
                self.stopWhiteNoise()
                self.stopSound()
                print("firetime is in the past")
            }
        }
        
        _alarmIsSet = true
        print("\(TAG): 10 alarm notifications scheduled.")
    }
    
    func cancelScheduleAlarm() {
        stopWhiteNoise()
        stopSound()
        let ids = (0..<10).map {
            "alarm_\($0)"
        }
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
        _alarmIsSet = false
        print("\(TAG): Canceled scheduled alarm.")
    }
    
}
