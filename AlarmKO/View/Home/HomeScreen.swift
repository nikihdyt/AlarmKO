//
//  MainView.swift
//  AlarmKO
//
//  Created by Niki Hidayati on 20/05/25.
//

import SwiftUI
import SwiftData
import AVFoundation

struct HomeScreen: View {
    
    let dummyAlarm = [
        Alarm(id: UUID(), time: Date.now, alarmRepeat: "Every Day", label: "Alarm but the name is long", game: "Punch", sound: "alarm.wav", isActive: false),
        Alarm(id: UUID(), time: Date.now, alarmRepeat: "Every Day", label: "Alarm 2", game: "Punch", sound: "alarm.wav", isActive: false),
        Alarm(id: UUID(), time: Date.now, alarmRepeat: "Every Day", label: "Alarm 3", game: "Punch", sound: "alarm.wav", isActive: false),
    ]
    
    @Environment(\.modelContext) var modelContext
    @Query private var alarms: [Alarm]
    
    @State private var selectedAlarm: Alarm? = nil
    @State private var showSheet: Bool = false
    @State private var alarmSet = false
    @State private var audioPlayer: AVAudioPlayer?
    
    @StateObject private var viewModel = HomeViewModel()
    @StateObject private var notificationManager = NotificationManager()
    
    var body: some View {
        NavigationStack {
            if alarms.isEmpty {
                VStack(alignment: .center) {
                    Spacer()
                    Text("Use the \"+\" button to add an alarm.")
                    Button {
                        testNotification()
                    } label: {
                        Text("Test Notification")
                            .foregroundStyle(.prim)
                            .padding()
                            .background(.darkGreen, in: .rect(cornerRadius: 20))
                    }
                }
                .onAppear {
                    UNUserNotificationCenter.current().delegate = notificationManager
                }
            }
            
            LazyVStack {
                ForEach(alarms) { alarm in
                    AlarmCardView(alarm: alarm)
                        .padding(.horizontal, 2)
                        .onTapGesture {
                            selectedAlarm = alarm
                            showSheet = true
                        }
                }
            }
            .vSpacing(.top)
            .padding(.horizontal, 20)
            .navigationTitle("Alarms")
            .toolbar {
                ToolbarItem {
                    Button {
                        selectedAlarm = nil
                        showSheet = true
                    } label: {
                        Image(systemName: "plus")
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                    }
                }
            }
            .sheet(isPresented: $showSheet) {
                AddAlarmView(alarm: $selectedAlarm)
            }
            .navigationDestination(isPresented: $notificationManager.navigateToGame) {
                PunchTrackerScreen()
            }
        }
        
    }
    
    /// Alarm Card
    @ViewBuilder
    private func AlarmCardView(alarm: Alarm) -> some View {
        ZStack {
            Image("bg_alarm_card")
                .resizable()
                .scaledToFit()
            
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        HStack {
                            Button {
                                modelContext.delete(alarm)
                            } label: {
                                Image("ic_trash")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                            }
                            .buttonStyle(.plain)
                            
                            Text(alarm.time.formatted(date: .omitted, time: .shortened))
                                .font(.title.bold())
                                .foregroundColor(.white)
                        }
                    }
                    
                    Text("\(alarm.label) | \(alarm.alarmRepeat)")
                        .foregroundColor(.white)
                        .lineLimit(1)
                }
                .hSpacing(.leading)
                
                Toggle(isOn: Binding(
                    get: { alarm.isActive },
                    set: { newValue in
                        alarm.isActive = newValue
                        try? modelContext.save()
                        
                        if newValue {
                            viewModel.scheduleAlarm(forTime: alarm.time)
                            print("Alarm scheduled for \(alarm.time) from toggle")
                        } else {
                            viewModel.cancelScheduleAlarm()
                            print("Alarm canceled")
                        }
                    })
                ) { }
                    .toggleStyle(SwitchToggleStyle(tint: Color("prim")))
                    .padding(.leading, 4)
                    .fixedSize()
            }
            .padding(.horizontal, 20)
        }
        .onAppear {
            viewModel.setupAudioSession()
            viewModel.stopWhiteNoise()
            if alarm.isActive {
                viewModel.scheduleAlarm(forTime: alarm.time)
                print("alarm set to \(alarm.time) when card appearing")
            }
        }
    }
    
    func testNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Test Notification"
        content.subtitle = "This is a test notification 🔔"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
        let request = UNNotificationRequest(identifier: "TEST_NOTIFICATION", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}

#Preview {
    HomeScreen()
        .preferredColorScheme(.dark)
}
