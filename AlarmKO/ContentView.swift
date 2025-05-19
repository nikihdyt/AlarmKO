//
//  ContentView.swift
//  AlarmKO
//
//  Created by Niki Hidayati on 19/05/25.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding = false
    
    var body: some View {
        if hasSeenOnboarding {
            MainView()
        } else {
            OnboardingView(hasSeenOnboarding: $hasSeenOnboarding)
        }    }
}

#Preview {
    ContentView()
}
