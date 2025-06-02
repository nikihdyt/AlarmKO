//
//  ContentView.swift
//  AlarmKOMainPage
//
//  Created by Joann ( Tang Chien ) on 28/05/25.
//

import SwiftUI

struct AlarmScreen: View {
    
    @StateObject private var alarmViewModel = AlarmViewModel()
    @StateObject private var notificationManager = NotificationManager()
    @StateObject private var alarmManager = AlarmManager()
    @State private var bedtimeReminderTime = Date()
    @State private var wakeUpTime = Date()
    
    @AppStorage("navState") private var navStateRaw: String = GameNavigationState.home.rawValue
    
    var navState: GameNavigationState {
        get { GameNavigationState(rawValue: navStateRaw) ?? .home }
        set { navStateRaw = newValue.rawValue }
    }
    
    @State private var navigateToAnotherScreen: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    HStack(spacing: 13) {
                        AlarmCard(
                            title: "Bed Time",
                            subtitle: "Tonight",
                            time: $bedtimeReminderTime,
                            icon: "BedtimeIcon",
                            iconColor: Color(.terti)
                        )
                        .onChange(of: bedtimeReminderTime) { _, newValue in
                            alarmViewModel.sleepTime = Calendar.current.dateComponents([.hour, .minute], from: newValue)
                        }
                        
                        AlarmCard(
                            title: "Wake Up",
                            subtitle: "Tomorrow",
                            time: $wakeUpTime,
                            icon: "AlarmIcon",
                            iconColor: Color(.terti)
                        )
                        .onChange(of: wakeUpTime) { _, newValue in
                            alarmViewModel.wakeUpTime = Calendar.current.dateComponents([.hour, .minute], from: newValue)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    CircularSleepRing(start: $bedtimeReminderTime, end: $wakeUpTime)
                        .padding()
                    
                    HStack {
                        Text("Repeat")
                            .font(.title3)
                            .bold()

                        Text(alarmViewModel.repeatDescription)
                            .foregroundColor(.secondary)
                        
                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, 20)
                    
                    WeekdaySelector(selectedDays: $alarmViewModel.selectedDays)
                        .padding(.horizontal, 20)
                    
                    Text("Settings")
                        .font(.title3)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                    
                    List {
                        Picker("Game", selection: $alarmViewModel.alarmGame) {
                            ForEach(AlarmGame.allCases, id: \.self) { game in
                                Text(game.rawValue)
                            }
                        }
                        
                        Toggle("Active", isOn: $alarmViewModel.isActive)
                        
                    }
                    .listStyle(InsetListStyle())
                    .frame(minHeight: 100)
                    .clipShape(.rect(cornerRadius: 20))
                    .scrollDisabled(true)
                    
                    Text("Games")
                        .font(.title3)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            Image("Game1")
                            Image("Game2")
                            Image("Game1")
                            Image("Game2")
                            Image("Game1")
                            Image("Game2")
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    Section("Audio Status") {
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
                .navigationTitle("AlarmKO")
                .navigationBarTitleDisplayMode(.inline)
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
                .background {
                    Color.black
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
                }
            }
            .scrollIndicators(.hidden)
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

#Preview {
    AlarmScreen()
        .preferredColorScheme(.dark)
}
