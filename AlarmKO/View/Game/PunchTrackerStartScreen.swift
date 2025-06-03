//
//  StartingScreen.swift
//  AlarmKO
//
//  Created by Ziqa on 01/06/25.
//

import SwiftUI

struct PunchTrackerStartScreen: View {
    
    let punchAmount = Text("10").foregroundStyle(.prim)
    let gAmount = Text("15g").foregroundStyle(.prim)
    
    @Binding var isStartGame: Bool
    
    var body: some View {
        VStack(spacing: 60) {
            Image("Punching Gloves")
            
            HStack {
                Image("AlarmKO Title")
                    .resizable()
                    .scaledToFill()
                
                Spacer()
                    .frame(maxWidth: .infinity)
            }
            
            Spacer(minLength: 0)
            
            VStack(alignment: .leading, spacing: 20) {
                Text("Mission:\nWake Up Warrior!")
                    .font(.largeTitle.bold())
                    .fixedSize()
                
                VStack(alignment: .leading, spacing: 5) {
                    
                    HStack {
                        Text("1")
                            .font(.title3.bold())
                            .foregroundStyle(.prim)
                        Text("Defeat the alarm with \(punchAmount) powerful punches.")
                    }
                    HStack {
                        Text("2")
                            .font(.title3.bold())
                            .foregroundStyle(.prim)
                        Text("Each punch must hit at least \(gAmount) force.")
                    }
                    HStack {
                        Text("3")
                            .font(.title3.bold())
                            .foregroundStyle(.prim)
                        Text("Missed hits don’t count — keep going!")
                    }
                    HStack {
                        Text("4")
                            .font(.title3.bold())
                            .foregroundStyle(.prim)
                        Text("Complete the combo to silence the alarm.")
                    }
                }
                .font(.subheadline)
                .foregroundStyle(.lightGray)
            }
            .hSpacing(.leading)
            .padding(.horizontal, 30)
            
            Button {
                isStartGame = true
            } label: {
                Text("Start Game!")
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .fontWeight(.semibold)
            }
            .buttonStyle(.borderedProminent)
            .foregroundColor(.black)
            .tint(Color.prim)
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 50)
    }
}

#Preview {
    PunchTrackerStartScreen(isStartGame: .constant(false))
        .preferredColorScheme(.dark)
}
