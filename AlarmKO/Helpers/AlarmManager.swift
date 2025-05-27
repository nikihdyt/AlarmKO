//
//  AlarmManager.swift
//  AlarmKO
//
//  Created by Ziqa on 23/05/25.
//

import SwiftUI
import AVFoundation

class AlarmManager {
    
    @Published var audioPlayer: AVAudioPlayer?
    @Published var whiteNoisePlayer: AVAudioPlayer?
    
    func setupAudioSession() {
        // Set the audio session to playback mode, which allows background audio
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Error setting up audio session: \(error.localizedDescription)")
        }
    }
    
    func playWhiteNoise() {
        
        guard let url = Bundle.main.url(forResource: "white_noise", withExtension: "mp3") else {
            print("White noise file not found")
            return
        }
        
        do {
            whiteNoisePlayer = try AVAudioPlayer(contentsOf: url)
            whiteNoisePlayer?.numberOfLoops = -1 // Loop indefinitely
            whiteNoisePlayer?.prepareToPlay()
            whiteNoisePlayer?.play()
        } catch {
            print("Error playing white noise: \(error.localizedDescription)")
        }
    }
    
    func stopWhiteNoise() {
        whiteNoisePlayer?.stop()
    }
    
    func playAlarmSound() {
        
        guard let url = Bundle.main.url(forResource: "alarm", withExtension: "wav") else {
            print("Sound file not found")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1 // Loop indefinitely
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("Error playing sound: \(error.localizedDescription)")
        }
    }
    
    func stopAlarmSound() {
        audioPlayer?.stop()
    }
    
}
