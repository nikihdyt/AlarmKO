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
    @Environment(\.modelContext) var modelContext
    @Query private var alarms: [Alarm]
    @State private var selectedAlarm: Alarm? = nil
    @State private var showSheet: Bool = false
    
    @State private var alarmSet = false
    @State private var audioPlayer: AVAudioPlayer?
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                VStack {
                    Button(action: {
                        selectedAlarm = nil
                        showSheet = true
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing, 12)
                    
                    Text("Alarms")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 153, height: 71)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 10)
                    
                    List {
                        ForEach(alarms) { alarm in
                            AlarmCardView(alarm: alarm)
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .onTapGesture {
                                    selectedAlarm = alarm
                                    showSheet = true
                                }
                        }
                    }
                    .listStyle(PlainListStyle())
                    .background(Color.black.ignoresSafeArea())
                    .padding(.top, -10)
                }
            }
            .background(.black)
            .sheet(isPresented: $showSheet) {
                AddAlarmView(alarm: $selectedAlarm)
            }
        }
    }
    
    @ViewBuilder
    private func AlarmCardView(alarm: Alarm) -> some View {
        ZStack {
            Image("bg_alarm_card")
                .resizable()
                .scaledToFit()
                .frame(width: 350, height: 100)
            
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        HStack(alignment: VerticalAlignment.center) {
                            Button(action: {
                                modelContext.delete(alarm)
                            }) {
                                Image("ic_trash")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                            }
                            .buttonStyle(.plain)
                            
                            Text(alarm.time.formatted(date: .omitted, time: .shortened))
                                .font(.system(size: 36))
                                .bold()
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.top, 15.5)
                    .padding(.bottom, -5)
                    
                    Text("\(alarm.game) | \(alarm.alarmRepeat)")
                        .font(.system(size: 16)
                        .weight(.light))
                        .foregroundColor(.white)
                        .padding(.bottom, 20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.leading, 20)
                
                Toggle("", isOn: Binding(
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
                    }))
                    .toggleStyle(SwitchToggleStyle(tint: Color(0xDBF173)))
                    .padding(.trailing, 38)
            }
        }
        .frame(width: 350, height: 100)
        .onAppear {
            viewModel.setupAudioSession()
            viewModel.stopWhiteNoise()
            if alarm.isActive {
                viewModel.scheduleAlarm(forTime: alarm.time)
                print("alarm set to \(alarm.time) when card appearing")
            }
        }
    }
}

#Preview {
    HomeScreen()
}
