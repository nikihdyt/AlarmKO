//
//  AddAlarmView.swift
//  AlarmKO
//
//  Created by Niki Hidayati on 20/05/25.
//

import SwiftUI

struct AddAlarmView: View {
    @State private var alarm = Alarm(
        time: Date(),
        alarmRepeat: "Never",
        label: "Alarm",
        game: "Punching",
        sound: "",
        isActive: true)
    
    var body: some View {
        ZStack {
            Color(0x323834)
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    Text("Cancel")
                        .foregroundColor(.white)
                        .font(.system(size: 17))
                    Spacer()
                    Text("Add Alarm")
                        .foregroundColor(.white)
                        .font(.system(size: 17, weight: .bold))
                    Spacer()
                    Text("Save")
                        .foregroundColor(.white)
                        .font(.system(size: 17))
                }
                .padding(.horizontal, 16.5)
                .padding(.top, 16)
                
                DatePicker("Select Time", selection: $alarm.time, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .colorScheme(.dark)
                    .environment(\.locale, Locale(identifier: "en_US"))
                
                ZStack {
                    List {
                        Section(header: EmptyView()) {
                            VStack {
                                HStack {
                                    Text("Repeat")
                                    Spacer()
                                    Button(action: {
                                        print("fesdnfl")
                                    }) {
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(Color(0x656A6A))
                                    }
                                }
                                .padding(.top, 11)
                                
                                Divider().background(Color.white.opacity(0.3))
                            }
                            
                            VStack {
                                HStack {
                                    Text("Label")
                                    Spacer()
                                    Button(action: {}) {
                                        Text(alarm.label)
                                            .foregroundColor(Color(0x656A6A))
                                    }
                                }
                                
                                Divider().background(Color.white.opacity(0.3))
                            }
                            
                            VStack {
                                HStack {
                                    Text("Game")
                                    Spacer()
                                    Button(action: {}) {
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(Color(0x656A6A))
                                    }
                                }
                                
                                Divider().background(Color.white.opacity(0.3))
                            }
                            
                            HStack {
                                Text("Sound")
                                Spacer()
                                Button(action: {
                                    
                                }) {
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(Color(0x656A6A))
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
                    .padding(.top, 9)
                    .padding(.horizontal, 14)
                    .scrollDisabled(true)
                    .frame(height: 218)
                }
                
                Spacer()
            }
        }
    }
}

#Preview {
    AddAlarmView()
}
