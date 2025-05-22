//
//  LevelerMotionManager.swift
//  AlarmKO
//
//  Created by Jeremy Lumban Toruan on 22/05/25.
//
import CoreMotion
import Foundation
import Combine

class MotionManager: ObservableObject {
    private var motionManager = CMMotionManager()
    @Published var pitch: Double = 0.0
    @Published var roll: Double = 0.0
    
    // New property for customizing update interval
    var updateInterval: TimeInterval = 0.02 {
        didSet {
            restartUpdates()
        }
    }
    
    init() {
        startUpdates()
    }
    
    private func restartUpdates() {
        motionManager.stopDeviceMotionUpdates()
        startUpdates()
    }
    
    func startUpdates() {
        motionManager.deviceMotionUpdateInterval = updateInterval
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, _ in
            guard let attitude = motion?.attitude else { return }
            
            // Apply low-pass filter for smoother readings
            if let currentPitch = self?.pitch, let currentRoll = self?.roll {
                let filterFactor: Double = 0.5
                self?.pitch = (attitude.pitch * 180 / .pi) * filterFactor + currentPitch * (1 - filterFactor)
                self?.roll = (attitude.roll * 180 / .pi) * filterFactor + currentRoll * (1 - filterFactor)
            } else {
                self?.pitch = attitude.pitch * 180 / .pi
                self?.roll = attitude.roll * 180 / .pi
            }
        }
    }
    
    deinit {
        motionManager.stopDeviceMotionUpdates()
    }
}

