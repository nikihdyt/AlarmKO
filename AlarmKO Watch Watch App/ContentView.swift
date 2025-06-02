//
//  ContentView.swift
//  AlarmKO Watch Watch App
//
//  Created by Jeremy Lumban Toruan on 02/06/25.
//

import SwiftUI

struct ContentView: View {
    
    
    @StateObject private var healthManager = HealthManager()
    
    var body: some View {
        List {
            VStack(alignment: .leading, spacing: 6) {
                Text("❤️ Heart Rate")
                    .font(.headline)
                Text("\(Int(healthManager.heartRate)) BPM")
                    .font(.title2)
            }
            .padding(.vertical, 4)
            
            VStack(alignment: .leading, spacing: 6) {
                Text("😴 Sleep Duration")
                    .font(.headline)
                Text(String(format: "%.1f hours", healthManager.sleepDuration))
                    .font(.title2)
            }
            .padding(.vertical, 4)
        }
        .listStyle(.plain)
        .navigationTitle("Health Stats")
        .refreshable {
        }
        .onAppear {
            healthManager.requestAuhtorization()
            healthManager.fetchRecentHeartRate()
            
            healthManager.fetchLastSleepDuration()
        }
        
    }
}

#Preview {
    ContentView()
}
