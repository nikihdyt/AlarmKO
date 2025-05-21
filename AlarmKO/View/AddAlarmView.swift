//
//  AddAlarmView.swift
//  AlarmKO
//
//  Created by Niki Hidayati on 20/05/25.
//

import SwiftUI

struct AddAlarmView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var alarm = Alarm(
        time: Date(),
        alarmRepeat: "Never",
        label: "Alarm",
        game: "Punching",
        sound: "Sound 2",
        isActive: true)
    let alarmSettings: [String] = ["Repeat", "Label", "Game", "Sound"]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(0x323834)
                    .ignoresSafeArea()
                
                VStack {
                    DatePicker("Select Time", selection: $alarm.time, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .colorScheme(.dark)
                        .environment(\.locale, Locale(identifier: "en_US"))
                    
                    ZStack {
                        List {
                            Section(header: EmptyView()) {
                                ForEach(alarmSettings, id: \.self) { item in
                                    VStack {
                                        if item == "Label" {
                                            HStack {
                                                Text(item)
                                                    .padding(.top, item == "Repeat" ? 5 : 0)
                                                Spacer()
                                                TextField("Label", text: $alarm.label)
                                                    .foregroundColor(Color(0x656A6A))
                                                    .multilineTextAlignment(.trailing)
                                                    .frame(width: 100)
                                            }
                                        } else {
                                            NavigationLink(destination: AlarmSettingItemView(title: item, selectedOption: bindingForItem(item)), label: {
                                                HStack {
                                                    Text(item)
                                                        .padding(.top, item == "Repeat" ? 5 : 0)
                                                    Spacer()
                                                    Text(valueForItem(item))
                                                        .foregroundColor(Color(0x656A6A))
                                                }
                                            })
                                        }
                                        
                                        if item != "Sound" {
                                            Divider().background(Color.white.opacity(0.3))
                                                .padding(.top, 5)
                                        }
                                    }
                                }
                            }
                            .listRowBackground(Color.clear)
                            .foregroundColor(.white)
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                        .background(Color(0x2C322E))
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .padding(.top, 5)
                        .padding(.horizontal, 14)
                        .scrollDisabled(true)
                        .frame(height: 60 * 4)
                    }
                    
                    Spacer()
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                        .foregroundColor(.white)
                        .font(.system(size: 17))
                    }
                    
                    ToolbarItem(placement: .principal) {Text("Add Alarm")
                            .foregroundColor(.white)
                            .font(.system(size: 17).bold())
                    }

                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Save") {
                            
                        }
                        .foregroundColor(.white)
                        .font(.system(size: 17))
                    }
                }
            }
        }
        .tint(.white)
    }
    
    func bindingForItem(_ item: String) -> Binding<String> {
        switch item {
        case "Repeat":
            return $alarm.alarmRepeat
        case "Game":
            return $alarm.game
        case "Sound":
            return $alarm.sound
        default:
            return .constant("")
        }
    }
    
    func valueForItem(_ item: String) -> String {
        switch item {
        case "Repeat":
            return alarm.alarmRepeat
        case "Label":
            return alarm.label
        case "Game":
            return alarm.game
        case "Sound":
            return alarm.sound
        default:
            return ""
        }
    }
}

#Preview {
    AddAlarmView()
}
