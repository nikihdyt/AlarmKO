//
//  AlarmSettingScreen.swift
//  AlarmKO
//
//  Created by Ziqa on 26/05/25.
//

import SwiftUI

struct AlarmSettingsScreen: View {
    
    @StateObject private var alarmSettings = AlarmSettings()
    @StateObject private var notificationManager = NotificationManager()
    @State private var sleepTime = Date()
    @State private var wakeUpTime = Date()
    
    var body: some View {
        NavigationView {
            Form {
                DatePicker(
                    "Sleep Time",
                    selection: $sleepTime,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.graphical)
                .onChange(of: sleepTime) { _, newValue in
                    alarmSettings.sleepTime = Calendar.current.dateComponents([.hour, .minute], from: newValue)
                }
                DatePicker(
                    "Wake Up Time",
                    selection: $wakeUpTime,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.graphical)
                .onChange(of: wakeUpTime) { _, newValue in
                    alarmSettings.wakeUpTime = Calendar.current.dateComponents([.hour, .minute], from: newValue)
                }
                
                Section("Repeat") {
                    WeekdaySelector(selectedDays: $alarmSettings.selectedDays)
                    
                    HStack {
                        Text("Selected:")
                        Spacer()
                        Text(alarmSettings.repeatDescription)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Settings") {
                    TextField("Label", text: $alarmSettings.label)
                    
                    Picker("Game", selection: $alarmSettings.alarmGame) {
                        ForEach(AlarmGame.allCases, id: \.self) { game in
                            Text(game.rawValue)
                        }
                    }
                    
                    Picker("Sound", selection: $alarmSettings.alarmSound) {
                        ForEach(AlarmSound.allCases, id: \.self) { sound in
                            Text(sound.rawValue).tag(sound)
                        }
                    }
                    
                    Toggle("Active", isOn: $alarmSettings.isActive)
                }
                
                Section("Debug") {
                    Button("Print UserDefaults to Console") {
                        printUserDefaults()
                    }
                    .foregroundColor(.blue)
                }
            }
            .navigationTitle("Alarm Settings")
            .onAppear {
                // Initialize date pickers with saved values
                alarmSettings.setNotificationManager(notificationManager)
                
                if let hour = alarmSettings.sleepTime.hour, let minute = alarmSettings.sleepTime.minute {
                    sleepTime = Calendar.current.date(from: DateComponents(hour: hour, minute: minute)) ?? Date()
                }
                if let hour = alarmSettings.wakeUpTime.hour, let minute = alarmSettings.wakeUpTime.minute {
                    wakeUpTime = Calendar.current.date(from: DateComponents(hour: hour, minute: minute)) ?? Date()
                }
            }
            
        }
    }
    
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
    AlarmSettingsScreen()
}
