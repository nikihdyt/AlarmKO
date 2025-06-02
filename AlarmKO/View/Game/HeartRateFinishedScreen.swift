//
//  HeartRateFinishedScreen.swift
//  AlarmKO
//
//  Created by Jeremy Lumban Toruan on 02/06/25.
//

import SwiftUI

struct HeartRateFinishedScreen: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var watchData = PhoneConnectivityManager()
    
    var body: some View {
        ZStack {
            // Background with brain/workout image
            VStack(spacing: 30) {
                // Close button
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(.gray)
                            .frame(width: 44, height: 44)
                            .background(Color.gray.opacity(0.2))
                            .clipShape(Circle())
                    }
                }
                .padding(.top, 20)
                .padding(.horizontal, 30)
                
                Spacer()
                
                // Main content
                VStack(spacing: 20) {
                    Text("Mission\naccomplished!")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .hSpacing(.leading)
                    
                    Text("Don't be this guy.")
                        .font(.title3)
                        .foregroundColor(.white)
                        .hSpacing(.leading)
                    
                    HStack {
                        Text("Wake up time")
                            .font(.title3)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Text(getCurrentWakeUpTime())
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.red)
                    }
                    .padding(.top, 30)
                }
                .padding(.horizontal, 30)
                
                Spacer()
                Spacer()
            }
        }
        .background {
            ZStack {
                Image(.finishScreenHR)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                LinearGradient(colors: [Color.black.opacity(0.99), Color.black.opacity(0.1)], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
            }
        }
        .navigationBarBackButtonHidden()
    }
    
    private func getCurrentWakeUpTime() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: Date())
    }
}

#Preview {
    HeartRateFinishedScreen()
        .preferredColorScheme(.dark)
}
