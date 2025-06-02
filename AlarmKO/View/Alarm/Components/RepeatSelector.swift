//
//  RepeatSelector.swift
//  AlarmKOMainPage
//
//  Created by Joann ( Tang Chien ) on 28/05/25.
//

import SwiftUI

struct RepeatSelector: View {
    @Binding var repeatDays: [Bool] // Pass in a Boolean array of length 7

    let weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

    var body: some View {
        HStack(spacing: 20) {
            ForEach(0..<7, id: \.self) { i in
                VStack(spacing: 4) {
                    Button(action: {
                        repeatDays[i].toggle()
                    }) {
                        Circle()
                            .fill(repeatDays[i] ? Color(.prim) : Color(.terti))
                               .frame(width: 30, height: 30)
                        //Neumorphism style of the circle
                               .shadow(color: repeatDays[i] ? .clear : Color.white.opacity(0.1), radius: 4, x: -2, y: -2)  // Top-left highlight
                               .shadow(color: repeatDays[i] ? .clear : Color.black.opacity(0.8), radius: 4, x: 2, y: 2)    // Bottom-right shadow
                    }

                    Text(weekdays[i])
                        .font(.caption2)
                        .foregroundColor(.white)
                }
            }
        }
 
    }
}

