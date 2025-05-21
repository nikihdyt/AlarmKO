//
//  AddAlarmView.swift
//  AlarmKO
//
//  Created by Niki Hidayati on 20/05/25.
//

import SwiftUI
import SwiftData

struct AddAlarmView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Binding var alarm: Alarm?
    @State private var time: Date = Date()
    @State private var alarmRepeat: String = ""
    @State private var label: String = ""
    @State private var game: String = ""
    @State private var sound: String = ""
    
    let alarmSettings: [String] = ["Repeat", "Label", "Game", "Sound"]
    
    var isEditMode: Bool {
        alarm != nil
    }
    
    private var backgroundColor: some View {
        Color(UIColor(red: 50/255, green: 56/255, blue: 52/255, alpha: 1)) // 0x323834
            .ignoresSafeArea()
    }
    
    private var timePicker: some View {
        DatePicker("Select Time", selection: $time, displayedComponents: .hourAndMinute)
            .datePickerStyle(.wheel)
            .labelsHidden()
            .colorScheme(.dark)
            .environment(\.locale, Locale(identifier: "en_US"))
    }
    
    private func labelCell() -> some View {
        HStack {
            Text("Label")
            Spacer()
            TextField("Label", text: $label)
                .foregroundColor(Color(UIColor(red: 101/255, green: 106/255, blue: 106/255, alpha: 1))) // 0x656A6A
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.leading, 20)
        }
    }
    
    private func navigationCell(for item: String) -> some View {
        NavigationLink(destination: AlarmSettingItemView(title: item, selectedOption: bindingForItem(item))) {
            HStack {
                Text(item)
                    .padding(.top, item == "Repeat" ? 5 : 0)
                Spacer()
                Text(valueForItem(item))
                    .foregroundColor(Color(UIColor(red: 101/255, green: 106/255, blue: 106/255, alpha: 1)))
            }
        }
        .id(valueForItem(item))
    }
    
    private var settingsList: some View {
        List {
            Section(header: EmptyView()) {
                ForEach(alarmSettings, id: \.self) { item in
                    if item == "Label" {
                        labelCell()
                    } else {
                        navigationCell(for: item)
                    }
                }
            }
            .listRowBackground(Color.clear)
            .foregroundColor(.white)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color(UIColor(red: 44/255, green: 50/255, blue: 46/255, alpha: 1)))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .padding(.top, 5)
        .padding(.horizontal, 14)
        .scrollDisabled(true)
        .frame(height: 60 * 4)
    }
    
    private var toolbarContent: some ToolbarContent {
        Group {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(.white)
                .font(.system(size: 17))
            }
            
            ToolbarItem(placement: .principal) {
                Text(isEditMode ? "Edit Alarm" : "Add Alarm")
                    .foregroundColor(.white)
                    .font(.system(size: 17).bold())
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    saveAlarm()
                }
                .foregroundColor(.white)
                .font(.system(size: 17))
            }
        }
    }
    
    func bindingForItem(_ item: String) -> Binding<String> {
        switch item {
        case "Repeat":
            return $alarmRepeat
        case "Game":
            return $game
        case "Sound":
            return $sound
        default:
            return Binding(get: { "" }, set: { _ in })
        }
    }
    
    func valueForItem(_ item: String) -> String {
        switch item {
        case "Repeat":
            return alarmRepeat
        case "Label":
            return label
        case "Game":
            return game
        case "Sound":
            return sound
        default:
            return ""
        }
    }
    
    private func saveAlarm() {
        if isEditMode, let existingAlarm = alarm {
            existingAlarm.time = time
            existingAlarm.label = label
            existingAlarm.alarmRepeat = alarmRepeat
            existingAlarm.game = game
            existingAlarm.sound = sound
        } else {
            let newAlarm = Alarm(
                time: time,
                alarmRepeat: alarmRepeat,
                label: label,
                game: game,
                sound: sound,
                isActive: true
            )
            modelContext.insert(newAlarm)
        }
        
        do {
            try modelContext.save()
        } catch {
            print("Failed to save alarm: \(error.localizedDescription)")
        }
        dismiss()
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                backgroundColor
                
                VStack {
                    timePicker
                    
                    ZStack {
                        settingsList
                    }
                    
                    Spacer()
                }
                .toolbar {
                    toolbarContent
                }
                .onAppear {
                    if let existingAlarm = alarm {
                        time = existingAlarm.time
                        alarmRepeat = existingAlarm.alarmRepeat
                        label = existingAlarm.label
                        game = existingAlarm.game
                        sound = existingAlarm.sound
                    }
                }
            }
        }
        .tint(.white)
    }
}

#Preview {
    AddAlarmView(alarm: .constant(nil))
}
