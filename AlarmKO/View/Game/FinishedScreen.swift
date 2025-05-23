//
//  FinishedScreen.swift
//  AlarmKO
//
//  Created by Ziqa on 22/05/25.
//

import SwiftUI

struct FinishedScreen: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 15) {
                HStack(alignment: .top) {
                    NavigationLink {
                        Text("Go to homescreen")
                    } label: {
                        Image(systemName: "xmark")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundStyle(.black.secondary)
                            .frame(width: 45, height: 45)
                            .background(.lightGray, in: .circle)
                            .contentShape(.circle)
                    }
                    
                    Spacer(minLength: 0)
                    
                    Button {
                        // Download
                    } label: {
                        Image(systemName: "square.and.arrow.down")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .frame(width: 45, height: 45)
                            .background(.darkGray, in: .circle)
                            .contentShape(.circle)
                    }
                }
                
                Spacer(minLength: 0)
                
                Text("Mission Accomplished!")
                    .font(.largeTitle.bold())
                    .hSpacing(.leading)
                
                Text("Winning mornings is winning life.")
                    .hSpacing(.leading)
                    .padding(.bottom, 40)
                
                HealthStatisticsCard()
                
                Spacer(minLength: 0)
                
                HStack(spacing: 8) {
                    Text("Top Punch")
                        .fontWeight(.bold)
                        .foregroundStyle(Color("prim"))
                    Spacer()
                    
                    Text("26 G | 929 km/h")
                        .font(.title3)
                }
                .hSpacing(.leading)
                
                HStack(spacing: 8) {
                    Text("Wake Up Time")
                        .fontWeight(.bold)
                        .foregroundStyle(Color("prim"))
                    Spacer(minLength: 0)
                    
                    Text("07:00 AM")
                        .font(.title3)
                    
                }
                
                Spacer(minLength: 0)
                
                NavigationLink {
                    PunchingHistoryScreen()
                } label: {
                    Text("Punching History")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color("prim"))
                        .padding(15)
                        .background {
                            LinearGradient(colors: [.lightGray, .darkGray.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing)
                                .opacity(0.9)
                        }
                        .clipShape(.capsule)
                        .shadow(color: .black, radius: 10, x: 2, y: 2)
                        .contentShape(.capsule)
                }
                
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 40)
            .background {
                ZStack {
                    Image(.finishScreenBG)
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                    
                    LinearGradient(colors: [Color.black.opacity(0.8), Color.black.opacity(0.1)], startPoint: .top, endPoint: .bottom)
                        .ignoresSafeArea()
                }
            }
        }
    }
    
    @ViewBuilder
    private func HealthStatisticsCard() -> some View {
        HStack(alignment: .center,spacing: 20) {
            VStack(spacing: 10) {
                Text("Heart Rate")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("76")
                    .font(.system(size: 50))
                    .fontWeight(.bold)
                    .foregroundStyle(Color("prim"))
                
                Text("BPM")
                    .font(.title3)
                    .fontWeight(.semibold)
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 20)
            .background {
                LinearGradient(colors: [.lightGray, .black.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .opacity(0.9)
            }
            .clipShape(.rect(cornerRadius: 20))
            .shadow(color: .black, radius: 4, x: 4, y: 4)
            
            VStack(spacing: 10) {
                Text("Time Asleep")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                HStack(spacing: 4) {
                    Text("5")
                        .font(.system(size: 50))
                        .fontWeight(.bold)
                        .foregroundStyle(Color("prim"))
                    
                    Text("hr")
                        .fontWeight(.semibold)
                        .offset(y: 10)
                    
                    Text("40")
                        .font(.system(size: 50))
                        .fontWeight(.bold)
                        .foregroundStyle(Color("prim"))
                    
                    Text("min")
                        .fontWeight(.semibold)
                        .offset(y: 10)
                }
            }
        }
    }
}

#Preview {
    FinishedScreen()
        .preferredColorScheme(.dark)
}
