//
//  AlarmSettingItemView.swift
//  AlarmKO
//
//  Created by Niki Hidayati on 20/05/25.
//

import SwiftUI

struct AlarmSettingItemView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) private var dismiss
    let title: String
    @Binding var selectedOption: String
    var options: [String] {
        switch title {
        case "Repeat":
            return ["Never", "Every Day", "Every Saturday", "Every Sunday"]
        case "Game":
            return ["Punching", "Game 2", "Game 3"]
        case "Sound":
            return ["Sound 1", "Sound 2", "Sound 3", "Sound 4"]
        default:
            return []
        }
    }
    
    var body: some View {
        ZStack {
            VStack {
                List {
                    Section() {
                        ForEach(options, id: \.self) { option in
                            Button {
                                selectedOption = option
                                print(selectedOption)
                                dismiss()
                            } label: {
                                Text(option)
                                    .foregroundColor(.white)
                            }
                            .listRowBackground(Color(0x2C322E))
                            .buttonStyle(.plain)
                        }
                    }
                }
                .listStyle(.plain)
                .background(Color(0x2C322E))
                .cornerRadius(10)
                .frame(height: 42 * CGFloat(options.count) + 15)
                .padding(.horizontal, 15)
                
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(0x323834))
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(title)
                    .foregroundColor(.white)
                    .font(.system(size: 17).bold())
            }
        }
    }
}

#Preview {
    AlarmSettingItemView(title: "Repeat", selectedOption: .constant("Never"))
}
