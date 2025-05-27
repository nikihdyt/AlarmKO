//
//  AddAlarmView.swift
//  AlarmKO
//
//  Created by Niki Hidayati on 20/05/25.
//

import SwiftUI
import SwiftData
import AVFoundation

//struct AddAlarmView: View {
//    
//    @Environment(\.modelContext) var modelContext
//    @Environment(\.dismiss) private var dismiss
//    
//    @Binding var alarm: Alarm?
//    
//    @State private var sleepTime: Date = Date()
//    @State private var wakeUpTime: Date = Date()
//    @State private var alarmRepeat: String = ""
//    @State private var label: String = ""
//    @State private var game: String = ""
//    @State private var sound: String = ""
//    
//    let alarmSettings: [String] = ["Repeat", "Label", "Game", "Sound"]
//    
//    var isEditMode: Bool {
//        alarm != nil
//    }
//    
//    var body: some View {
//        NavigationView {
//            VStack {
//                HStack(spacing: 50) {
//                    VStack {
//                        Text("Sleep Time")
//                        DatePicker("Select Time", selection: $sleepTime, displayedComponents: .hourAndMinute)
//                            .labelsHidden()
//                            .environment(\.locale, Locale(identifier: "en_GB"))
//                    }
//                    
//                    VStack {
//                        Text("Wake Up Time")
//                        DatePicker("Select Time", selection: $wakeUpTime, displayedComponents: .hourAndMinute)
//                            .labelsHidden()
//                            .environment(\.locale, Locale(identifier: "en_GB"))
//                    }
//                }
//                
//                List {
//                    Section {
//                        ForEach(alarmSettings, id: \.self) { item in
//                            if item == "Label" {
//                                labelCell()
//                            } else {
//                                navigationCell(for: item)
//                            }
//                        }
//                    }
//                    .listRowBackground(Color("dark_green"))
//                }
//                .scrollContentBackground(.hidden)
//                .scrollDisabled(true)
//            }
//            .background {
//                Color("seco")
//                    .ignoresSafeArea()
//            }
//            .toolbar {
//                Group {
//                    ToolbarItem(placement: .navigationBarLeading) {
//                        Button("Cancel") {
//                            dismiss()
//                        }
//                        .foregroundColor(.white)
//                    }
//                    
//                    ToolbarItem(placement: .principal) {
//                        Text(isEditMode ? "Edit Alarm" : "Add Alarm")
//                            .foregroundColor(.white)
//                            .fontWeight(.bold)
//                    }
//                    
//                    ToolbarItem(placement: .navigationBarTrailing) {
//                        Button("Save") {
//                            saveAlarm()
//                        }
//                        .foregroundColor(.white)
//                    }
//                }
//            }
//            .onAppear {
//                if let existingAlarm = alarm {
//                    sleepTime = existingAlarm.sleepTime
//                    wakeUpTime = existingAlarm.wakeUpTime
//                    alarmRepeat = existingAlarm.alarmRepeat
//                    label = existingAlarm.label
//                    game = existingAlarm.game
//                    sound = existingAlarm.sound
//                }
//            }
//            .onChange(of: alarmRepeat) { _, newValue in
//                alarm?.alarmRepeat = newValue
//            }
//            .onChange(of: game) { _, newValue in
//                alarm?.game = newValue
//            }
//            .onChange(of: sound) { _, newValue in
//                alarm?.sound = newValue
//            }
//        }
////        tint(.white)
//    }
//    
//    @ViewBuilder
//    private func labelCell() -> some View {
//        HStack {
//            Text("Label")
//            
//            Spacer()
//            
//            TextField("Label", text: $label)
//                .foregroundColor(Color(.white))
//                .multilineTextAlignment(.trailing)
//                .padding(.leading, 20)
//        }
//    }
//    
//    @ViewBuilder
//    private func navigationCell(for item: String) -> some View {
//        NavigationLink {
//            AlarmSettingItemView(title: item, selectedOption: bindingForItem(item))
//        } label: {
//            HStack {
//                Text(item)
//                    .padding(.top, item == "Repeat" ? 5 : 0)
//                
//                Spacer()
//                
//                Text(valueForItem(item))
//                    .foregroundColor(Color(.white))
//            }
//        }
//    }
//    
//    func bindingForItem(_ item: String) -> Binding<String> {
//        switch item {
//        case "Repeat":
//            return $alarmRepeat
//        case "Game":
//            return $game
//        case "Sound":
//            return $sound
//        default:
//            return Binding(get: { "" }, set: { _ in })
//        }
//    }
//    
//    func valueForItem(_ item: String) -> String {
//        switch item {
//        case "Repeat":
//            return alarmRepeat
//        case "Label":
//            return label
//        case "Game":
//            return game
//        case "Sound":
//            return sound
//        default:
//            return ""
//        }
//    }
//    
//    private func zeroSeconds(from date: Date) -> Date {
//        let calendar = Calendar.current
//        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
//        return calendar.date(from: components)!
//    }
//    
//    private func saveAlarm() {
//        if isEditMode, let existingAlarm = alarm {
//            existingAlarm.sleepTime = sleepTime
//            existingAlarm.wakeUpTime = wakeUpTime
//            existingAlarm.label = label
//            existingAlarm.alarmRepeat = alarmRepeat
//            existingAlarm.game = game
//            existingAlarm.sound = sound
//        } else {
//            let newAlarm = Alarm(
//                sleepTime: sleepTime,
//                wakeUpTime: zeroSeconds(from: wakeUpTime),
//                alarmRepeat: alarmRepeat,
//                label: label,
//                game: game,
//                sound: sound,
//                isActive: true
//            )
//            modelContext.insert(newAlarm)
//        }
//        
//        do {
//            try modelContext.save()
//            print(alarm)
//            print("Alarm saved")
//        } catch {
//            print("Failed to save alarm: \(error.localizedDescription)")
//        }
//        dismiss()
//    }
//}
//
//#Preview {
//    AddAlarmView(alarm: .constant(nil))
//        .colorScheme(.dark)
//}
