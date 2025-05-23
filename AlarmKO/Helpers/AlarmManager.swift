import Foundation
import AVFoundation

final class AlarmManager: ObservableObject {
    
    private var audioPlayer: AVAudioPlayer?
    private var whiteNoisePlayer: AVAudioPlayer?
    private var scheduledWorkItems: [DispatchWorkItem] = []
    
    private var isAlarmplaying: Bool = false
    
    func setupAudioSession() {
        do {
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
            whiteNoisePlayer = try AVAudioPlayer(contentsOf: url)
            whiteNoisePlayer?.numberOfLoops = -1
            whiteNoisePlayer?.prepareToPlay()
            whiteNoisePlayer?.play()
        } catch {
            print("Error playing white noise: \(error.localizedDescription)")
        }
    }

    func stopWhiteNoise() {
        whiteNoisePlayer?.stop()
    }

    func playSound() {
//        setupAudioSession()
        guard let url = Bundle.main.url(forResource: "alarm", withExtension: "wav") else {
            print("Alarm sound not found")
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("Error playing alarm: \(error.localizedDescription)")
        }
    }

    func stopSound() {
        audioPlayer?.stop()
    }
    
    func changeIsAlarmPlayingToTrue(value isa: Bool) {
        self.isAlarmplaying = isa
    }

    func scheduleAlarms(at alarmTime: Date, onTrigger: @escaping () -> Void) {
        cancelAlarms() // Reset existing
        
        playWhiteNoise()
        
        for i in 0..<10 {
            let fireTime = Calendar.current.date(byAdding: .second, value: i * 9, to: alarmTime)!
            let delay = fireTime.timeIntervalSinceNow
            
            if delay > 0 {
                
                
                let workItem = DispatchWorkItem {
//                    if self.isAlarmplaying == true {
//                        self.stopWhiteNoise()
//                        self.playSound() 
//                    }
                    self.stopWhiteNoise()
                    self.playSound()
                    onTrigger()
                    print("Alarm #\(i) played at \(Date())")
                }
                scheduledWorkItems.append(workItem)
                DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem)
            }
        }
    }

    func cancelAlarms() {
        scheduledWorkItems.forEach { $0.cancel() }
        scheduledWorkItems.removeAll()
        stopWhiteNoise()
        stopSound()
        
        isAlarmplaying = false
        print("All local alarms canceled.")
    }
    
    func stopAlarmEffects() {
        audioPlayer?.stop()
        audioPlayer = nil
        
        whiteNoisePlayer?.stop()
        whiteNoisePlayer = nil
    }

}

