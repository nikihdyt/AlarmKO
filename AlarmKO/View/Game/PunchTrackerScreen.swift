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
    
    // TODO: Implement Swift Data or State to update punches left and punches done
    
    var punches: [Punches] = [
        Punches(name: "punchesLeft", amount: 10),
        Punches(name: "punchesDone", amount: 2),
    ]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 15) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Punch forward 10x")
                        .font(.largeTitle.bold())
                    
                    Text("Move your phone to the speed of 10 G!")
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 20)
                .hSpacing(.leading)
                
                Spacer(minLength: 0)
                
                PunchTrackerView(punches)
                
                Spacer(minLength: 0)
                
                LiveAccelerationCardView()
                
                Text("A pro boxer's punch hits with 53-65Gs - that's up to 2,296 km/h of force.")
                    .foregroundStyle(.secondary)
                
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
        let punchesLeft = punches.first(where: { $0.name == "punchesLeft" })!.amount
        
        VStack(spacing: 20) {
            ZStack {
                Chart(punches, id: \.name) { punch in
                    SectorMark(angle: .value("Amount", punch.amount), innerRadius: .ratio(0.83), angularInset: 8)
                        .cornerRadius(200)
                        .foregroundStyle(self.colorForPunch(punch.name).gradient)
                }
                .frame(width: 240, height: 240)
                
                Text("10")
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
                .scaledToFit()
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Live Acceleration")
                    .font(.title3)
                    .fontWeight(.heavy)
                
                Text("0,88 G")
                    .font(.largeTitle)
                    .fontWeight(.black)
                    .foregroundStyle(Color("Primary"))
                
                HStack(spacing: 0) {
                    Text("929")
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
