//
//  WeekdaySelector.swift
//  AlarmKO
//
//  Created by Ziqa on 02/06/25.
//

import SwiftUI

struct WeekdaySelector: View {
    @Binding var selectedDays: Set<AlarmRepeat>
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
            ForEach(AlarmRepeat.allCases, id: \.self) { day in
                Button {
                    if selectedDays.contains(day) {
                        selectedDays.remove(day)
                    } else {
                        selectedDays.insert(day)
                    }
                } label: {
                    Text(day.shortName)
                        .font(.caption)
                        .fontWeight(.medium)
                        .frame(width: 45, height: 45)
                        .background(selectedDays.contains(day) ? Color.prim : Color.darkGray)
                        .foregroundColor(selectedDays.contains(day) ? .black : .primary)
                        .clipShape(Circle())
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

//#Preview {
//    
//}
