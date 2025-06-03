//
//  AlarmManager.swift
//  AlarmKO
//
//  Created by Ziqa on 23/05/25.
//

import SwiftUI
import AVFoundation

@MainActor
class AlarmManager: ObservableObject {
    
    @Published var alarmPlayer: AVAudioPlayer?
    @Published var whiteNoisePlayer: AVAudioPlayer?
    @Published var isWhiteNoisePlaying = false
    @Published var isAlarmPlaying = false
    
//    private var whiteNoiseTimer: Timer?
    private var alarmTimer: Timer?
    private var alarmViewModel: AlarmViewModel?
//    private let whiteNoiseLeadTime: TimeInterval = 60
    
    private let TAG = "Alarm Manager: "
    
    init() {
        setupAudioSession()
    }
    
    func setAlarmViewModel(_ viewModel: AlarmViewModel) {
            self.alarmViewModel = viewModel
        }
    
    
    func setupAudioSession() {
        // Set the audio session to playback mode, which allows background audio
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
            print("\(TAG)Audio session configured to bypass silent switch")
        } catch {
            print("Error setting up audio session: \(error.localizedDescription)")
        }
    }
    
    func scheduleAlarm(for alarmViewModel: AlarmViewModel) async {
        cancelAlarmSequence()
        
        guard alarmViewModel.isActive else {
            print("\(TAG)Alarm is not active")
            stopWhiteNoise()
            return
        }
        
        let selectedDays = alarmViewModel.selectedDays
        guard !selectedDays.isEmpty else {
            print("\(TAG)No days selected for alarm")
            stopWhiteNoise()
            return
        }
        
        startWhiteNoise()
    }
    
    func scheduleAlarmSequence() {
        guard let viewModel = alarmViewModel else {
            print("\(TAG) No alarm viewmodel provided")
            return
        }
        
        guard viewModel.isActive else {
            print("\(TAG) Alarm is not active")
            return
        }
        
        cancelAlarmSequence()
        
        startWhiteNoise()
        
        for day in viewModel.selectedDays {
            scheduleForDay(day: day, viewModel: viewModel)
        }
    }
    
    private func scheduleForDay(day: AlarmRepeat, viewModel: AlarmViewModel) {
            let now = Date()
            let calendar = Calendar.current
            
            guard let wakeHour = viewModel.wakeUpTime.hour,
                  let wakeMinute = viewModel.wakeUpTime.minute else {
                print("\(TAG)Invalid wake up time settings")
                return
            }
            
            // Get the next occurrence of this weekday
            let targetWeekday = weekdayToCalendarWeekday(day)
            let currentWeekday = calendar.component(.weekday, from: now)
            
            var daysToAdd = targetWeekday - currentWeekday
            if daysToAdd < 0 {
                daysToAdd += 7 // Next week
            }
            
            // If it's today, check if we haven't passed the alarm time yet
            if targetWeekday == currentWeekday {
                let todayWakeTime = calendar.date(bySettingHour: wakeHour, minute: wakeMinute, second: 0, of: now)
                if let todayWake = todayWakeTime {
                    if todayWake > now {
                        daysToAdd = 0 // Use today
                    } else {
                        daysToAdd = 7 // Schedule for next week
                    }
                }
            } else if daysToAdd == 0 {
                daysToAdd = 7 // If same weekday but already passed, next week
            }
            
            guard let targetDate = calendar.date(byAdding: .day, value: daysToAdd, to: now) else {
                print("\(TAG)Could not calculate target date")
                return
            }
            
            // Create wake time for the target date
            guard let wakeTime = calendar.date(bySettingHour: wakeHour, minute: wakeMinute, second: 0, of: targetDate) else {
                print("\(TAG)Could not create wake time")
                return
            }
            
            // Only schedule alarm timer if wake time is in the future
            if wakeTime > now {
                scheduleAlarmTimer(for: wakeTime)
            }
            
            print("\(TAG)Scheduled alarm for \(day.rawValue): \(formatTime(wakeTime))")
        }
    
    
    
    private func scheduleAlarmTimer(for alarmTime: Date) {
        let timeInterval = alarmTime.timeIntervalSinceNow
        
        if timeInterval > 0 {
            alarmTimer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { [weak self] _ in
                Task { @MainActor in
                    self?.switchToAlarmSound()
                }
            }
            print("\(TAG)Alarm timer scheduled for \(timeInterval) seconds from now (\(formatTime(alarmTime)))")
        }
    }
    
    func cancelAlarmSequence() {
        alarmTimer?.invalidate()
        alarmTimer = nil
        
        stopAlarmSound()
        stopWhiteNoise()
        
        print("\(TAG)Alarm sequence canceled")
    }
    
    func startWhiteNoise() {
        guard let url = Bundle.main.url(forResource: "silent", withExtension: "wav") else {
            print("\(TAG) White noise file not found")
            return
        }
        
        do {
            stopAlarmSound()
            whiteNoisePlayer = try AVAudioPlayer(contentsOf: url)
            whiteNoisePlayer?.numberOfLoops = -1 // Loop indefinitely
            whiteNoisePlayer?.prepareToPlay()
            whiteNoisePlayer?.play()
            
            isWhiteNoisePlaying = true
            print("\(TAG) White noise started")
        } catch {
            print("\(TAG) Error playing white noise: \(error.localizedDescription)")
        }
    }
    
    func stopWhiteNoise() {
        whiteNoisePlayer?.stop()
        whiteNoisePlayer = nil
        isWhiteNoisePlaying = false
        print("\(TAG)White noise stopped")
    }
    
    func switchToAlarmSound() {
        print("\(TAG)Switching from white noise to alarm sound")
        stopWhiteNoise()
        playAlarmSound()
    }
    
    func playAlarmSound() {
        guard let url = Bundle.main.url(forResource: "alarm", withExtension: "wav") else {
            print("\(TAG) Sound file not found")
            return
        }
        
        do {
            alarmPlayer = try AVAudioPlayer(contentsOf: url)
            alarmPlayer?.numberOfLoops = -1 // Loop indefinitely
            alarmPlayer?.prepareToPlay()
            alarmPlayer?.play()
            
            isAlarmPlaying = true
            print("\(TAG) Alarm sound started")
        } catch {
            print("\(TAG) Error playing sound: \(error.localizedDescription)")
        }
    }
    
    func stopAlarmSound() {
        alarmPlayer?.stop()
        alarmPlayer = nil
        isAlarmPlaying = false
        print("\(TAG)Alarm sound stopped")
    }
    
    func stopAllSounds() {
        stopWhiteNoise()
        stopAlarmSound()
        cancelAlarmSequence()
    }
    
    // MARK: - Helper Methods
    
    private func weekdayToCalendarWeekday(_ day: AlarmRepeat) -> Int {
            switch day {
            case .sunday: return 1
            case .monday: return 2
            case .tuesday: return 3
            case .wednesday: return 4
            case .thursday: return 5
            case .friday: return 6
            case .saturday: return 7
            }
        }
    
    private func calendarWeekdayToWeekday(_ calendarWeekday: Int) -> AlarmRepeat {
        switch calendarWeekday {
        case 1: return .sunday
        case 2: return .monday
        case 3: return .tuesday
        case 4: return .wednesday
        case 5: return .thursday
        case 6: return .friday
        case 7: return .saturday
        default: return .monday
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    // MARK: - Debug Methods
    func printCurrentStatus() {
        print("\(TAG)=== ALARM MANAGER STATUS ===")
        print("White noise playing: \(isWhiteNoisePlaying)")
        print("Alarm playing: \(isAlarmPlaying)")
        print("Alarm timer active: \(alarmTimer != nil)")
        
        if let settings = alarmViewModel {
            print("Alarm active: \(settings.isActive)")
            print("Sleep time: \(settings.sleepTime.hour ?? 0):\(String(format: "%02d", settings.sleepTime.minute ?? 0))")
            print("Wake time: \(settings.wakeUpTime.hour ?? 0):\(String(format: "%02d", settings.wakeUpTime.minute ?? 0))")
            print("Selected days: \(settings.selectedDays.map { $0.rawValue }.joined(separator: ", "))")
        }
        print("=== END STATUS ===")
    }
    
    // MARK: - Manual Controls (for testing)
    func manualStartWhiteNoise() {
        startWhiteNoise()
    }
    
    func manualStartAlarm() {
        playAlarmSound()
    }
    
}


/*
 
 private func scheduleForDay(day: AlarmRepeat, viewModel: AlarmViewModel) {
         let now = Date()
         let calendar = Calendar.current
         
         guard let sleepHour = viewModel.sleepTime.hour,
               let sleepMinute = viewModel.sleepTime.minute,
               let wakeHour = viewModel.wakeUpTime.hour,
               let wakeMinute = viewModel.wakeUpTime.minute else {
             print("\(TAG)Invalid time settings")
             return
         }
         
         // Get the next occurrence of this weekday
         let targetWeekday = weekdayToCalendarWeekday(day)
         let currentWeekday = calendar.component(.weekday, from: now)
         
         var daysToAdd = targetWeekday - currentWeekday
         if daysToAdd <= 0 {
             daysToAdd += 7 // Next week
         }
         
         // But if it's today and we haven't passed the sleep time yet, use today
         if targetWeekday == currentWeekday {
             let todaySleepTime = calendar.date(bySettingHour: sleepHour, minute: sleepMinute, second: 0, of: now)
             if let todaySleep = todaySleepTime, todaySleep > now {
                 daysToAdd = 0 // Use today
             }
         }
         
         guard let targetDate = calendar.date(byAdding: .day, value: daysToAdd, to: now) else {
             print("\(TAG)Could not calculate target date")
             return
         }
         
         // Create sleep and wake times for the target date
         guard let sleepTime = calendar.date(bySettingHour: sleepHour, minute: sleepMinute, second: 0, of: targetDate),
               var wakeTime = calendar.date(bySettingHour: wakeHour, minute: wakeMinute, second: 0, of: targetDate) else {
             print("\(TAG)Could not create target times")
             return
         }
         
         // If wake time is before sleep time, it's the next day
         if wakeTime <= sleepTime {
             wakeTime = calendar.date(byAdding: .day, value: 1, to: wakeTime) ?? wakeTime
         }
         
         // Only schedule if both times are in the future
         if sleepTime > now {
             scheduleSleepTimer(for: sleepTime)
         }
         
         if wakeTime > now {
             scheduleAlarmTimer(for: wakeTime)
         }
         
         print("\(TAG)Scheduled for \(day.rawValue): sleep at \(formatTime(sleepTime)), wake at \(formatTime(wakeTime))")
     }
 
 */
