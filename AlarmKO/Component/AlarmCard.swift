//
//  AlarmCard.swift
//  AlarmKO
//
//  Created by Niki Hidayati on 20/05/25.
//

import SwiftUI

struct AlarmCard: View {
    @Binding var alarm: Alarm
    
    var body: some View {
        ZStack {
            Image("bg_alarm_card")
                .resizable()
                .scaledToFit()
                .frame(width: 350, height: 100)
            
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        HStack(alignment: VerticalAlignment.center) {
                            Button(action: { }) {
                                Image("ic_trash")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                            }
                            
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
                
                Toggle("", isOn: $alarm.isActive)
                    .toggleStyle(SwitchToggleStyle(tint: Color(0xDBF173)))
                    .padding(.trailing, 38)
            }
        }
        .frame(width: 350, height: 100)
    }
}

#Preview {
    @Previewable @State var sampleAlarm = Alarm(
            time: Date(),
            alarmRepeat: "Never",
            label: "Alarm",
            game: "Punching",
            sound: "",
            isActive: true
        )

    AlarmCard(alarm: $sampleAlarm)
}
