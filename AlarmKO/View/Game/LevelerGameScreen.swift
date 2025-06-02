//
//  LevelerGameScreen.swift
//  AlarmKO
//
//  Created by Jeremy Lumban Toruan on 22/05/25.
//

import SwiftUI
import Combine

struct LevelerGameScreen: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var motion = LevelerMotionManager()
    @StateObject private var gameState = GameState()
    @State private var collisionTimer: Timer?
    @State private var showingTutorial = true
    @State var isTargetReached: Bool = false
    @AppStorage("navState") private var navState: String = GameNavigationState.game.rawValue
    
    // Sensitivity with smoother values
    private let pitchSensitivity: CGFloat = 9.0   // Slightly reduced from 10.0
    private let rollSensitivity: CGFloat = 6.0    // Slightly reduced from 7.0
    
    // Tutorial color
    private let tutorialBackgroundColor = Color(hex: "556058")
    
    var body: some View {
        ZStack {
            // Background
            Color.black.opacity(0.1).edgesIgnoringSafeArea(.all)
            
            if !showingTutorial {
                gameContent
            }
            
            // Tutorial overlay
            if showingTutorial || gameState.isGameOver {
                tutorialOverlay
            }
        }
        .onAppear {
            // Improve motion manager update interval
            motion.updateInterval = 0.02 // Faster update rate (50Hz)
            gameState.startGame()
            
            // Tutorial shows on start, game actually begins after dismissing tutorial
            showingTutorial = true
        }
        .onDisappear {
            collisionTimer?.invalidate()
        }
        .navigationBarBackButtonHidden()
        .navigationDestination(isPresented: $isTargetReached) {
            FinishedScreen()
        }
//        .onAppear() {
//            if navState == GameNavigationState.home.rawValue {
//                dismiss()
//            }
//        }
    }
    
    private var gameContent: some View {
        ZStack {
            // Player dot with improved animation
            Circle()
                .fill(Color(hex: "DBF173"))
                .frame(width: 30, height: 30)
                .offset(
                    x: CGFloat(motion.roll * Double(rollSensitivity)),
                    y: CGFloat(motion.pitch * Double(pitchSensitivity))
                )
                .animation(.interpolatingSpring(stiffness: 300, damping: 15), value: motion.pitch + motion.roll)
            
            // Target dots with animation
            ForEach(gameState.targets) { target in
                Circle()
                    .fill(Color.red)
                    .frame(width: 35, height: 35)
                    .position(target.position)
                    .scaleEffect(target.isPulsing ? 1.2 : 1.0)  // Pulsing effect
                    .animation(.easeInOut(duration: 0.3).repeatForever(), value: target.isPulsing)
            }
            
            // Score overlay
            VStack {
                Text("Score: \(gameState.score)")
                    .font(.title)
                    .padding()
                
                // Time remaining indicator
                Text("Time: \(gameState.timeRemaining)s")
                    .font(.title3)
                    .foregroundColor(gameState.timeRemaining <= 10 ? .red : .primary)
                    .scaleEffect(gameState.timeRemaining <= 10 && gameState.timeRemaining % 2 == 0 ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: gameState.timeRemaining)
                
                Spacer()
            }
        }
    }
    
    private var tutorialOverlay: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.7)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                Text(gameState.isGameOver ? "Game Over!" : "How to Play")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                
                if gameState.isGameOver {
                    Text("Final Score: \(gameState.score)")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding(.bottom, 10)
                } else {
                    VStack(alignment: .leading, spacing: 20) {
                        tutorialItem(
                            icon: "⬆️",
                            text: "Tilt your device to move the green dot"
                        )
                        
                        tutorialItem(
                            icon: "🔴",
                            text: "Collect red targets by touching them with your green dot"
                        )
                        
                        tutorialItem(
                            icon: "⏱️",
                            text: "Targets disappear after 2 seconds"
                        )
                        
                        tutorialItem(
                            icon: "🎮",
                            text: "Game ends after 45 seconds"
                        )
                    }
                    .padding()
                }
                
                Button(gameState.isGameOver ? "Play Again" : "Start Game") {
                    if gameState.isGameOver {
                        gameState.startGame()
                        showingTutorial = false
                    } else {
                        showingTutorial = false
                        startCollisionTimer()
                    }
                }
                .font(.system(size: 20))
                .bold()
                .padding(.horizontal, 40)
                .padding(.vertical, 15)
                .background(Color(hex: "DBF173"))
                .foregroundColor(.black)
                .cornerRadius(15)
                .shadow(radius: 2)
                
                if gameState.isGameOver {
                    Button("Finish Game") {
                        navState = GameNavigationState.home.rawValue // reset navState
                        isTargetReached = true
                    }
                    .font(.system(size: 20))
                    .bold()
                    .padding(.horizontal, 40)
                    .padding(.vertical, 15)
                    .background(Color(hex: "DBF173"))
                    .foregroundColor(.black)
                    .cornerRadius(15)
                    .shadow(radius: 2)
                }
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(tutorialBackgroundColor)
            )
            .padding(30)
        }
    }
    
    private func tutorialItem(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 15) {
            Text(icon)
                .font(.title)
            
            Text(text)
                .font(.body)
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
        }
    }
    
    private func startCollisionTimer() {
        // Check collisions 60 times per second for immediate response
        collisionTimer = Timer.scheduledTimer(withTimeInterval: 1/60, repeats: true) { _ in
            checkCollisions()
        }
    }
    
    func checkCollisions() {
        let playerPosition = CGPoint(
            x: UIScreen.main.bounds.width / 2 + CGFloat(motion.roll * Double(rollSensitivity)),
            y: UIScreen.main.bounds.height / 2 + CGFloat(motion.pitch * Double(pitchSensitivity)))
        
        // Use withAnimation to make the removal visible immediately
        withAnimation(.easeOut(duration: 0.1)) {
            gameState.checkCollisions(playerPosition: playerPosition)
        }
    }
}

// Extension to create Color from hex string
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

class GameState: ObservableObject {
    @Published var score = 0
    @Published var targets: [Target] = []
    @Published var isGameOver = false
    @Published var timeRemaining = 45
    
    private var timer: Timer?
    private var targetTimer: Timer?
    private var timeTimer: Timer?
    private var gameTime = 45.0
    
    func startGame() {
        resetGame()
        scheduleTargets()
        
        // Game timer
        timer = Timer.scheduledTimer(withTimeInterval: gameTime, repeats: false) { [weak self] _ in
            self?.endGame()
        }
        
        // Countdown timer
        timeRemaining = Int(gameTime)
        timeTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            }
        }
    }
    
    func resetGame() {
        score = 0
        targets = []
        isGameOver = false
        timeRemaining = Int(gameTime)
        timer?.invalidate()
        targetTimer?.invalidate()
        timeTimer?.invalidate()
    }
    
    private func endGame() {
        isGameOver = true
        timer?.invalidate()
        targetTimer?.invalidate()
        timeTimer?.invalidate()
    }
    
    private func scheduleTargets() {
        // Create new targets more frequently
        targetTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self, !self.isGameOver else {
                timer.invalidate()
                return
            }
            
            self.addRandomTarget()
            
            // Add bonus targets as game progresses (every 15 seconds)
            if self.timeRemaining % 15 == 0 && self.timeRemaining > 0 {
                // Add a bonus cluster of targets
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.addRandomTarget()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    self.addRandomTarget()
                }
            }
        }
    }
    
    private func addRandomTarget() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        let position = CGPoint(
            x: CGFloat.random(in: 50...(screenWidth - 50)),
            y: CGFloat.random(in: 50...(screenHeight - 50))
        )
        
        let target = Target(position: position, isPulsing: true)
        targets.append(target)
        
        // Remove target after 2 seconds if not caught
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            guard let self = self else { return }
            
            withAnimation(.easeOut(duration: 0.1)) {
                self.targets.removeAll { $0.id == target.id }
            }
        }
    }
    
    func checkCollisions(playerPosition: CGPoint) {
        let hitTargetIDs = targets.filter { target in
            let distance = sqrt(
                pow(target.position.x - playerPosition.x, 2) +
                pow(target.position.y - playerPosition.y, 2)
            )
            return distance < 32.5 // Hit radius
        }.map { $0.id }
        
        if !hitTargetIDs.isEmpty {
            // First update score
            score += hitTargetIDs.count
            
            // Then remove targets
            targets.removeAll { hitTargetIDs.contains($0.id) }
        }
    }
}

struct Target: Identifiable {
    let id = UUID()
    let position: CGPoint
    let isPulsing: Bool
}

#Preview {
    LevelerGameScreen()
}
