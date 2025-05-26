//
//  AlarmKOApp.swift
//  AlarmKO
//
//  Created by Niki Hidayati on 19/05/25.
//

import SwiftUI
import SwiftData

@main
struct AlarmKOApp: App {
    
    @StateObject var notificationManager = NotificationManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(notificationManager)
        }
        .modelContainer(for: Alarm.self)
    }
}

extension Color {
    init(_ hex: Int, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: opacity
        )
    }
}
