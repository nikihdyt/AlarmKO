//
//  HeartRateGameScreen.swift
//  AlarmKO
//
//  Created by Jeremy Lumban Toruan on 02/06/25.
//

import SwiftUI

struct HeartRateGameScreen: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var watchData = PhoneConnectivityManager()
    @State private var gameState: HeartRateGameState = .instruction
    @State private var timeRemaining = 10
    @State private var timer: Timer?
    @State var isTargetReached: Bool = false
    @AppStorage("navState") private var navState: String = GameNavigationState.game.rawValue
    
    private let targetHeartRate = 75
    private let requiredDuration = 10
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background with pulse pattern
                Color.black
                    .ignoresSafeArea()
                
                if gameState == .instruction {
                    instructionView
                } else {
                    gameView
                }
            }
            .navigationBarBackButtonHidden()
            .navigationDestination(isPresented: $isTargetReached) {
                HeartRateFinishedScreen()
            }
            .onChange(of: watchData.bpm) { oldValue, newValue in
                handleHeartRateChange(newValue)
            }
        }
    }
    
    private var instructionView: some View {
        VStack(spacing: 40) {
            // Back button
            HStack {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(.white)
                }
                
                Spacer()
                
                
                // Invisible spacer for centering
                HStack(spacing: 8) {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
                .opacity(0)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            Spacer()
            
            // Heart icon with pulse animation
            ZStack {
                // Pulse effect background
                PulseEffectView()
                
                // Heart icon
                Image(systemName: "heart.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.red)
                    .scaleEffect(1.0)
                    .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: gameState)
            }
            .frame(height: 200)
            
            Spacer()
            
            // Mission instructions
            VStack(alignment: .leading, spacing: 20) {
                Text("Mission:\nJumping jacks!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .fixedSize()
                
                VStack(alignment: .leading, spacing: 5) {
                    InstructionRow(number: "1", text: "Your heart rate must reach \(targetHeartRate) bpm.")
                    InstructionRow(number: "2", text: "Hold the bpm for 10 seconds!")
                    InstructionRow(number: "3", text: "Real time heart tracking.")
                    InstructionRow(number: "4", text: "Hit the target, wake up!")
                }
            }
            .hSpacing(.leading)
            .padding(.horizontal, 30)
            
            Spacer()
            
            // Get started button
            Button {
                startGame()
            } label: {
                Text("Start Game!")
                    .frame(maxWidth: .infinity)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(Color.red)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
    }
    
    private var gameView: some View {
        VStack(spacing: 30) {
            // Header
            HStack {
                Button {
                    stopGame()
                    dismiss()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(.white)
                }
                
                Spacer()
                
                // Invisible spacer for centering
                HStack(spacing: 8) {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
                .opacity(0)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            Spacer()
            
            // Exercise instruction
            Text("Let's do some\njumping jacks!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            // Heart rate display
            VStack(spacing: 16) {
                Text("Pulse Rate")
                    .font(.title3)
                    .foregroundColor(.red)
                
                // Main BPM display
                Text("\(Int(watchData.bpm))")
                    .font(.system(size: 120, weight: .bold))
                    .foregroundColor(.white)
                    .scaleEffect(watchData.bpm >= Double(targetHeartRate) ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 0.3), value: watchData.bpm >= Double(targetHeartRate))
                
                Text("BPM")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            // Target and timer
            VStack(spacing: 12) {
                Text("Heart rate must reach \(targetHeartRate) bpm")
                    .font(.body)
                    .foregroundColor(.gray)
                
                Text("Keep it for")
                    .font(.body)
                    .foregroundColor(.gray)
                
                // Timer display
                Text(String(format: "%02d:%02d", timeRemaining / 60, timeRemaining % 60))
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(timeRemaining < requiredDuration ? .red : .red.opacity(0.7))
                    .scaleEffect(timeRemaining < requiredDuration ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 0.3), value: timeRemaining)
            }
            
            Spacer()
        }
    }
    
    private func startGame() {
        gameState = .playing
        timeRemaining = requiredDuration
    }
    
    private func stopGame() {
        timer?.invalidate()
        timer = nil
        gameState = .instruction
        timeRemaining = requiredDuration
    }
    
    private func handleHeartRateChange(_ heartRate: Double) {
        guard gameState == .playing else { return }
        
        if heartRate >= Double(targetHeartRate) {
            // Start or continue timer if heart rate is above target
            if timer == nil {
                startTimer()
            }
        } else {
            // Reset timer if heart rate drops below target
            resetTimer()
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                // Goal achieved!
                completeGame()
            }
        }
    }
    
    private func resetTimer() {
        timer?.invalidate()
        timer = nil
        timeRemaining = requiredDuration
    }
    
    private func completeGame() {
        timer?.invalidate()
        timer = nil
        navState = GameNavigationState.home.rawValue
        isTargetReached = true
    }
}

struct InstructionRow: View {
    let number: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number)
                .font(.body)
                .fontWeight(.bold)
                .foregroundColor(.red)
            
            Text(text)
                .foregroundColor(.gray)
        }
    }
}

struct PulseEffectView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            ForEach(0..<3) { i in
                Circle()
                    .stroke(Color.red.opacity(0.3), lineWidth: 2)
                    .scaleEffect(isAnimating ? 1.5 : 0.5)
                    .opacity(isAnimating ? 0 : 1)
                    .animation(
                        .easeOut(duration: 1.5)
                        .repeatForever(autoreverses: false)
                        .delay(Double(i) * 0.5),
                        value: isAnimating
                    )
            }
        }
        .frame(width: 120, height: 120)
        .onAppear {
            isAnimating = true
        }
    }
}

enum HeartRateGameState {
    case instruction
    case playing
}

#Preview {
    HeartRateGameScreen()
        .preferredColorScheme(.dark)
}
