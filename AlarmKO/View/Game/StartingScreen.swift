//
//  StartingScreen.swift
//  AlarmKO
//
//  Created by Ziqa on 01/06/25.
//

import SwiftUI

struct StartingScreen: View {
    
    let punchAmount = Text("10").foregroundStyle(.prim)
    let gAmount = Text("5").foregroundStyle(.prim)
    
    var body: some View {
        VStack(spacing: 60) {
            Image("Punching Gloves")
            
            HStack {
                Image("AlarmKO Title")
                    .resizable()
                    .scaledToFit()
                
                Spacer()
                    .frame(width: 70)
            }
            
            Spacer(minLength: 0)
            
            VStack(alignment: .leading, spacing: 20) {
                Text("Mission:\nWake Up Warrior!")
                .font(.largeTitle.bold())
                .fixedSize()
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("① Defeat the alarm with \(punchAmount) powerful punches.")
                    Text("② Each punch must hit at least \(gAmount)g force.")
                    Text("③ Missed hits don’t count — keep going!")
                    Text("④ Complete the combo to silence the alarm.")
                }
                .font(.subheadline)
                .foregroundStyle(.lightGray)
            }
            .hSpacing(.leading)
            .padding(.horizontal, 30)
                        
            Button {
                // Move to game screen
            } label: {
                Text("Get Started")
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
    StartingScreen()
        .preferredColorScheme(.dark)
}
