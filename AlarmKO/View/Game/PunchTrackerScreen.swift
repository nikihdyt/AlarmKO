//
//  PunchTrackerScreen.swift
//  AlarmKO
//
//  Created by Ziqa on 21/05/25.
//

import SwiftUI
import Charts

struct Punches {
    var name: String
    var amount: Int
}

struct PunchTrackerScreen: View {
    @StateObject private var motionManager = PunchingMotionManager()
    
    private let targetPunches = 10
    
    // Computed property to get punches data from motion manager
    private var punches: [Punches] {
        let punchesDone = motionManager.punches.count
        let punchesLeft = max(0, targetPunches - punchesDone)
        
        return [
            Punches(name: "punchesLeft", amount: punchesLeft),
            Punches(name: "punchesDone", amount: punchesDone),
        ]
    }
    
    // Check if target is reached
    private var isTargetReached: Bool {
        motionManager.punches.count >= targetPunches
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 15) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Punch forward \(targetPunches)x")
                        .font(.largeTitle.bold())
                    
                    Text("Move your phone to the speed of 20 G!")
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 20)
                .hSpacing(.leading)
                
                // Success message when target is reached
                if isTargetReached {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.title2)
                        
                        Text("Target Reached! 🎉")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(10)
                }
                
                Spacer(minLength: 0)
                
                PunchTrackerView(punches)
                
                Spacer(minLength: 0)
                
                LiveAccelerationCardView()
                
                Text("A pro boxer's punch hits with 53-65Gs - that's up to 2,296 km/h of force.")
                    .foregroundStyle(.secondary)
                
                // Reset button
                Button(action: {
                    motionManager.resetPunches()
                }) {
                    Text("Reset Punches")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 12)
                        .background(Color.red.opacity(0.8))
                        .cornerRadius(10)
                }
                .padding(.top, 10)
                
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 20)
            .navigationTitle("Punch Tracker")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    /// Punch Tracker View
    @ViewBuilder
    private func PunchTrackerView(_ punches: [Punches]) -> some View {
        let punchesLeft = punches.first(where: { $0.name == "punchesLeft" })?.amount ?? 0
        
        VStack(spacing: 20) {
            ZStack {
                Chart(punches, id: \.name) { punch in
                    SectorMark(angle: .value("Amount", punch.amount), innerRadius: .ratio(0.83), angularInset: 8)
                        .cornerRadius(200)
                        .foregroundStyle(self.colorForPunch(punch.name).gradient)
                }
                .frame(width: 240, height: 240)
                
                // Show punches left in the center
                Text("\(punchesLeft)")
                    .font(.system(size: 80).bold())
                    .foregroundStyle(.white)
            }
            
            HStack(spacing: 0) {
                Text("\(punchesLeft)")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(Color("Primary"))
                
                Text(" Punches Left")
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
            }
        }
        .padding(15)
    }
    
    private func colorForPunch(_ name: String) -> Color {
        switch name {
        case "punchesLeft":
            return Color("Primary")
        case "punchesDone":
            return Color("Secondary")
        default:
            return .gray
        }
    }
    
    /// Live Acceleration Card View
    @ViewBuilder
    private func LiveAccelerationCardView() -> some View {
        ZStack {
            Image("Acceleration Card")
                .resizable()
                .scaledToFill()
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Live Acceleration")
                    .font(.title3)
                    .fontWeight(.heavy)
                
                // Show real-time acceleration from motion manager
                Text(String(format: "%.2f G", motionManager.latestAcceleration))
                    .font(.largeTitle)
                    .fontWeight(.black)
                    .foregroundStyle(Color("Primary"))
                
                HStack(spacing: 0) {
                    // Convert G-force to km/h (using the same conversion as in MotionManager)
                    let kmh = motionManager.latestAcceleration * 35.3
                    Text(String(format: "%.0f", kmh))
                        .font(.title3)
                        .foregroundStyle(Color("Primary"))
                    
                    Text(" km/h")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
            }
            .hSpacing(.leading)
            .padding(.horizontal, 30)
        }
    }
}

#Preview {
    PunchTrackerScreen()
        .preferredColorScheme(.dark)
}
