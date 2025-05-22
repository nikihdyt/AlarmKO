//
//  PunchingHistoryScreen.swift
//  AlarmKO
//
//  Created by Ziqa on 22/05/25.
//

import SwiftUI

struct PunchingHistoryScreen: View {
    var body: some View {
        NavigationStack {
            ScrollView(.vertical) {
                LazyVStack(alignment: .leading, spacing: 20) {
                    Text("Top Punch")
                        .font(.title3.bold())
                    
                    TopPunchStatsCards()
                    
                    Text("Punch Log")
                        .font(.title3.bold())
                    
                    ForEach(0..<10, id: \.self) { _ in
                        PunchLogCard()
                    }
                    
                }
                .vSpacing(.topLeading)
                .hSpacing(.leading)
                .padding(.horizontal, 20)
                .padding(.vertical, 15)
                .navigationTitle("Punching History")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
    
    @ViewBuilder
    private func TopPunchStatsCards() -> some View {
        HStack {
            ZStack {
                Image(.topPunchCard)
                    .resizable()
                    .scaledToFit()
                
                VStack {
                    Text("26,3")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.darkGray)
                    
                    Text("Gravity")
                        .font(.callout)
                        .foregroundStyle(.darkGray)
                }
            }
            
            ZStack {
                Image(.topPunchCard)
                    .resizable()
                    .scaledToFit()
                
                VStack {
                    Text("929")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.darkGray)
                    
                    Text("km/h")
                        .font(.callout)
                        .foregroundStyle(.darkGray)
                }
            }
        }
    }
    
    @ViewBuilder
    private func PunchLogCard() -> some View {
        ZStack {
            Image(.punchLogCard)
                .resizable()
                .scaledToFit()
            
            HStack {
                HStack {
                    VStack (alignment: .leading,spacing: 2) {
                        Text("Time (s)")
                            .font(.caption)
                        
                        Text("9.12.18")
                            .font(.title3.bold())
                    }
                    .hSpacing(.leading)
                    .padding(.leading, 80)
                    
                }
                .hSpacing(.leading)
                
                HStack {
                    VStack (alignment: .leading,spacing: 2) {
                        Text("Gravity")
                            .font(.caption)
                        
                        Text("13,52 G")
                            .font(.title3.bold())
                    }
                    .hSpacing(.leading)
                    .padding(.leading, 70)
                }
            }
        }
    }
}

#Preview {
    PunchingHistoryScreen()
        .preferredColorScheme(.dark)
}
