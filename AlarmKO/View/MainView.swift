//
//  MainView.swift
//  AlarmKO
//
//  Created by Niki Hidayati on 20/05/25.
//

import SwiftUI

struct MainView: View {
    @State private var alarms: [Alarm] = [
        Alarm(time: Date(), alarmRepeat: "Never", game: "Punching", isActive: true),
        Alarm(time: Date().addingTimeInterval(3600), alarmRepeat: "Every Day", game: "Punching", isActive: false)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                VStack {
                    Button(action: {
                        print("Button tapped!")
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
                        ForEach($alarms) { $alarm in
                            AlarmCard(alarm: $alarm)
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                    .listStyle(PlainListStyle())
                    .background(Color.black.ignoresSafeArea())
                    
                }
            }
        }
    }
}

#Preview {
    MainView()
}
