//
//  AlarmSettings.swift
//  AlarmKO
//
//  Created by Ziqa on 26/05/25.
//

import SwiftUI

@MainActor
class AlarmSettings: ObservableObject {
    @Published var sleepTime: DateComponents {
        didSet { saveSettings() }
    }
    @Published var wakeUpTime: DateComponents {
        didSet { saveSettings() }
    }
    @Published var selectedDays: Set<AlarmRepeat> {
        didSet { saveSettings() }
    }
    @Published var alarmGame: AlarmGame {
        didSet { saveSettings() }
    }
    @Published var alarmSound: AlarmSound {
        didSet { saveSettings() }
    }
    @Published var label: String {
        didSet { saveSettings() }
    }
    @Published var isActive: Bool {
        didSet { saveSettings() }
    }
    
    init() {
        self.sleepTime = DateComponents(
            hour: UserDefaults.standard.integer(forKey: "sleepHour"),
            minute: UserDefaults.standard.integer(forKey: "sleepMinute")
        )
        self.wakeUpTime = DateComponents(
            hour: UserDefaults.standard.integer(forKey: "wakeHour") == 0 ? 7 : UserDefaults.standard.integer(forKey: "wakeHour"),
            minute: UserDefaults.standard.integer(forKey: "wakeMinute")
        )
        self.selectedDays = UserDefaults.standard.getSet(forKey: "selectedDays", type: AlarmRepeat.self)
        self.alarmGame = AlarmGame(rawValue: UserDefaults.standard.string(forKey: "alarmGame") ?? "") ?? .punching
        self.alarmSound = AlarmSound(rawValue: UserDefaults.standard.string(forKey: "alarmSound") ?? "") ?? .beep
        self.label = UserDefaults.standard.string(forKey: "alarmLabel") ?? ""
        self.isActive = UserDefaults.standard.bool(forKey: "alarmActive")
        
        // Set default sleep time if not set
        if sleepTime.hour == 0 && sleepTime.minute == 0 {
            sleepTime = DateComponents(hour: 22, minute: 0)
        }
        
        // Set default selected days if empty
        if selectedDays.isEmpty {
            selectedDays = Set(AlarmRepeat.allCases)
        }
    }
    
    private func saveSettings() {
        UserDefaults.standard.set(sleepTime.hour ?? 0, forKey: "sleepHour")
        UserDefaults.standard.set(sleepTime.minute ?? 0, forKey: "sleepMinute")
        UserDefaults.standard.set(wakeUpTime.hour ?? 0, forKey: "wakeHour")
        UserDefaults.standard.set(wakeUpTime.minute ?? 0, forKey: "wakeMinute")
        UserDefaults.standard.set(selectedDays, forKey: "selectedDays")
        UserDefaults.standard.set(alarmGame.rawValue, forKey: "alarmGame")
        UserDefaults.standard.set(alarmSound.rawValue, forKey: "alarmSound")
        UserDefaults.standard.set(label, forKey: "alarmLabel")
        UserDefaults.standard.set(isActive, forKey: "alarmActive")
    }
    
    var repeatDescription: String {
        if selectedDays.count == 7 {
            return "Every day"
        } else if selectedDays.count == 5 && !selectedDays.contains(.saturday) && !selectedDays.contains(.sunday) {
            return "Weekdays"
        } else if selectedDays.count == 2 && selectedDays.contains(.saturday) && selectedDays.contains(.sunday) {
            return "Weekends"
        } else if selectedDays.count == 1 {
            return selectedDays.first?.rawValue ?? ""
        } else {
            return selectedDays.sorted { weekdayOrder($0) < weekdayOrder($1) }
                .map { $0.shortName }
                .joined(separator: ", ")
        }
    }
    
    private func weekdayOrder(_ day: AlarmRepeat) -> Int {
        switch day {
        case .sunday: return 0
        case .monday: return 1
        case .tuesday: return 2
        case .wednesday: return 3
        case .thursday: return 4
        case .friday: return 5
        case .saturday: return 6
        }
    }
}
