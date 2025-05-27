//
//  ContentView.swift
//  AlarmKO
//
//  Created by Niki Hidayati on 19/05/25.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding = false
    @AppStorage("isNavigateToGame") var isNavigateToGame = false
    
    var body: some View {
        if hasSeenOnboarding {
            AlarmScreen()
                .preferredColorScheme(.dark)
        } else {
            OnboardingScreen(hasSeenOnboarding: $hasSeenOnboarding)
                .preferredColorScheme(.dark)
        }
    }
}

#Preview {
    ContentView()
}
