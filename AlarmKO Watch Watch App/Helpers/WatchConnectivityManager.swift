//
//  WatchConnectivityManager.swift
//  AlarmKO
//
//  Created by Jeremy Lumban Toruan on 02/06/25.
//

import Foundation
import WatchConnectivity
import WatchKit
import AVFoundation

class WatchConnectivityManager: NSObject, WCSessionDelegate {
    
    final let TAG: String = "Watch Connectivity Manger:"
    
    static let shared = WatchConnectivityManager()
    
    override init() {
        super.init()
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
      
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func sendHeartRateToPhone(_ bpm: Double) {
        if WCSession.default.activationState == .activated {
            do {
                try WCSession.default.updateApplicationContext(["heart rate": bpm])
                print("\(TAG) Heart rate sent via: \(bpm)")
            } catch {
                print("\(TAG) Error sending heart rate: \(error.localizedDescription)")
            }
        }
    }
    
}


