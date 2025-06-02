//
//  AlarmCard.swift
//  AlarmKOMainPage
//
//  Created by Joann ( Tang Chien ) on 28/05/25.
//

import SwiftUI

struct AlarmCard: View {
    var title: String
    var subtitle: String
    @Binding var time: Date
    var icon: String
    var iconColor: Color
    @State private var showingTimePicker = false
    
    var body: some View {
        VStack(alignment: .leading){
            HStack(spacing: 8) {
                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                VStack(alignment: .leading){
                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(Font.custom("SF Pro", size: 13))
                        .foregroundColor(.white.opacity(0.4))
                        .kerning(1)
                }
            }
            Text(time.formatted(date: .omitted, time: .shortened))
                .font(.system(size: 32, weight: .heavy))
                .kerning(1)
                .foregroundColor(.white)
        }
        .padding(.vertical, 12)
        .padding(.trailing, 25)
        .frame(width: 170, height: 110)
        .background(Color("terti"))
        .cornerRadius(15)
        .sheet(isPresented: $showingTimePicker) {
            TimePickerSheet(selectedTime: $time, title: title)
        }
        .onTapGesture {
            showingTimePicker = true
        }
    }
}

struct TimePickerSheet: View {
    @Binding var selectedTime: Date
    let title: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Set \(title.lowercased())")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.top)
                
                DatePicker(
                    "Time",
                    selection: $selectedTime,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                
                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    AlarmCard(title: "Wake Up", subtitle: "wake up", time: .constant(Date()), icon: "AlarmIcon", iconColor: .terti)
}

