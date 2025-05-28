//
//  MotionManager.swift
//  AlarmCH2TestNots
//
//  Created by Jeremy Lumban Toruan on 22/05/25.
//


//
//  MotionManager.swift
//  TestingChallenge2-1
//
//  Created by Jeremy Lumban Toruan on 05/05/25.
//

import Foundation
import CoreMotion
import Combine

class PunchingMotionManager: ObservableObject {
    private var motionManager = CMMotionManager()
    private let updateInterval = 1.0 / 60.0 // 60Hz
    private let threshold = 3.0 // G-forces (can be tuned)

    @Published var latestAcceleration: Double = 0.0
    @Published var punches: [(timestamp: Date, peak: Double)] = []

    private var currentPeak: Double = 0.0
    private var isPunchInProgress = false
    
    var topPunch: (peak: Double, kmh: Double)? {
        guard let max = punches.max(by: { $0.peak < $1.peak }) else { return nil }
        // Rough estimate: 1 G ≈ 35.3 km/h (based on punch speed estimates)
        let kmh = max.peak * 35.3
        return (peak: max.peak, kmh: kmh)
    }

    init() {
        startUpdates()
    }

    func startUpdates() {
        motionManager.accelerometerUpdateInterval = updateInterval
        motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, _ in
            guard let self, let acc = data?.acceleration else { return }

            let magnitude = sqrt(acc.x * acc.x + acc.y * acc.y + acc.z * acc.z)
            self.latestAcceleration = magnitude

            // Detect punch start
            if magnitude > self.threshold {
                self.currentPeak = max(self.currentPeak, magnitude)
                if !self.isPunchInProgress {
                    self.isPunchInProgress = true
                    self.currentPeak = magnitude
                }
            }

            // Detect punch end
            if self.isPunchInProgress && magnitude < 1.5 {
                self.isPunchInProgress = false
                self.punches.append((timestamp: Date(), peak: self.currentPeak))
                self.currentPeak = 0.0
            }
        }
    }
    
    // Reset punches function for the UI
    func resetPunches() {
        punches.removeAll()
        currentPeak = 0.0
        isPunchInProgress = false
    }

    deinit {
        motionManager.stopAccelerometerUpdates()
    }
}
