//
//  alarmViewModelcreen.swift
//  AlarmKO
//
//  Created by Ziqa on 26/05/25.
//

import SwiftUI

struct AlarmScreen: View {
    
    @StateObject private var alarmViewModel = AlarmViewModel()
    @StateObject private var notificationManager = NotificationManager()
    @StateObject private var alarmManager = AlarmManager()
    @State private var bedtimeReminderTime = Date()
    @State private var wakeUpTime = Date()
    @StateObject private var watchData = PhoneConnectivityManager()
    
    @AppStorage("navState") private var navStateRaw: String = GameNavigationState.home.rawValue
    
    var navState: GameNavigationState {
        get { GameNavigationState(rawValue: navStateRaw) ?? .home }
        set { navStateRaw = newValue.rawValue }
    }
    
    @State private var navigateToAnotherScreen: Bool = false
    
    var body: some View {
        NavigationStack {
            Form {
                DatePicker(
                    "Bedtime Reminder",
                    selection: $bedtimeReminderTime,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.graphical)
                .onChange(of: bedtimeReminderTime) { _, newValue in
                    alarmViewModel.sleepTime = Calendar.current.dateComponents([.hour, .minute], from: newValue)
                }
                
                DatePicker(
                    "Wake Up Time",
                    selection: $wakeUpTime,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.graphical)
                .onChange(of: wakeUpTime) { _, newValue in
                    alarmViewModel.wakeUpTime = Calendar.current.dateComponents([.hour, .minute], from: newValue)
                }
                
                Section("Repeat") {
                    WeekdaySelector(selectedDays: $alarmViewModel.selectedDays)
                    
                    HStack {
                        Text("Selected:")
                        Spacer()
                        Text(alarmViewModel.repeatDescription)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Testing") {
                    NavigationLink(destination: HeartRateGameScreen()) {
                        Text("Test Heart Rate Game")
                            .foregroundColor(.blue)
                    }
                }
                
                Section("Settings") {
                    TextField("Label", text: $alarmViewModel.label)
                    
                    Picker("Game", selection: $alarmViewModel.alarmGame) {
                        ForEach(AlarmGame.allCases, id: \.self) { game in
                            Text(game.rawValue)
                        }
                    }
                    
                    Picker("Sound", selection: $alarmViewModel.alarmSound) {
                        ForEach(AlarmSound.allCases, id: \.self) { sound in
                            Text(sound.rawValue).tag(sound)
                        }
                    }
                    
                    Toggle("Active", isOn: $alarmViewModel.isActive)
                }
                
                Section("Audio Status") {
                    
                    Text("\(watchData.bpm) BPM")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.red)
                    
                    HStack {
                        Text("White Noise:")
                        Spacer()
                        Text(alarmManager.isWhiteNoisePlaying ? "Playing" : "Stopped")
                            .foregroundColor(alarmManager.isWhiteNoisePlaying ? .green : .gray)
                    }
                    
                    HStack {
                        Text("Alarm Sound:")
                        Spacer()
                        Text(alarmManager.isAlarmPlaying ? "Playing" : "Stopped")
                            .foregroundColor(alarmManager.isAlarmPlaying ? .red : .gray)
                    }
                }
                
                Section("Manual Controls") {
                    Button("Test White Noise") {
                        alarmManager.manualStartWhiteNoise()
                    }
                    .foregroundColor(.blue)
                    
                    Button("Test Alarm Sound") {
                        alarmManager.manualStartAlarm()
                    }
                    .foregroundColor(.red)
                    
                    Button("Stop All Sounds") {
                        alarmManager.stopAllSounds()
                    }
                    .foregroundColor(.orange)
                }
                
                Section("Debug") {
                    Button("Print UserDefaults to Console") {
                        printUserDefaults()
                    }
                    .foregroundColor(.blue)
                    
                    Button("Print Scheduled Notifications") {
                        Task {
                            await notificationManager.printScheduledNotifications()
                        }
                    }
                    .foregroundColor(.blue)
                    
                    Button("Print Alarm Manager Status") {
                        alarmManager.printCurrentStatus()
                    }
                    .foregroundColor(.blue)
                }
            }
            .navigationTitle("Alarm Settings")
            .onAppear {
                // Initialize date pickers with saved values
                alarmViewModel.setNotificationManager(notificationManager)
                alarmViewModel.setAlarmManager(alarmManager)
                
                if let hour = alarmViewModel.sleepTime.hour, let minute = alarmViewModel.sleepTime.minute {
                    bedtimeReminderTime = Calendar.current.date(from: DateComponents(hour: hour, minute: minute)) ?? Date()
                }
                if let hour = alarmViewModel.wakeUpTime.hour, let minute = alarmViewModel.wakeUpTime.minute {
                    wakeUpTime = Calendar.current.date(from: DateComponents(hour: hour, minute: minute)) ?? Date()
                }
                
            }
            .onChange(of: navStateRaw) { _, newValue in
                if newValue == GameNavigationState.game.rawValue {
                    print("navState: \(navState) in the AlarmScreen")
                    navigateToAnotherScreen = true
                }
            }
            .navigationDestination(isPresented: $navigateToAnotherScreen) {
                if alarmViewModel.alarmGame.rawValue == "Punching Game" {
                    PunchTrackerScreen()
                } else if alarmViewModel.alarmGame.rawValue == "Leveler Game" {
                    LevelerGameScreen()
                }
                else if alarmViewModel.alarmGame.rawValue == "Heart Rate Game" {
                    HeartRateGameScreen()
                }
            }
            
        }
    }
    
    
    // MARK: Debug print
    func printUserDefaults() {
        print("=== ALARM USERDEFAULTS DEBUG ===")
        
        let keys = [
            "sleepHour", "sleepMinute",
            "wakeHour", "wakeMinute",
            "selectedDays", "alarmGame",
            "alarmSound", "alarmLabel",
            "alarmActive"
        ]
        
        for key in keys {
            let value = UserDefaults.standard.object(forKey: key) ?? "nil"
            print("\(key): \(value)")
        }
        
        print("=== END DEBUG ===")
    }
}

struct WeekdaySelector: View {
    @Binding var selectedDays: Set<AlarmRepeat>
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
            ForEach(AlarmRepeat.allCases, id: \.self) { day in
                Button {
                    if selectedDays.contains(day) {
                        selectedDays.remove(day)
                    } else {
                        selectedDays.insert(day)
                    }
                } label: {
                    Text(day.shortName)
                        .font(.caption)
                        .fontWeight(.medium)
                        .frame(width: 40, height: 40)
                        .background(selectedDays.contains(day) ? Color.blue : Color.gray.opacity(0.2))
                        .foregroundColor(selectedDays.contains(day) ? .white : .primary)
                        .clipShape(Circle())
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    AlarmScreen()
}
