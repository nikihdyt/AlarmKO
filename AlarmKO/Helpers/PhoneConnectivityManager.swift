//
//  PhoneConnectivityManager.swift
//  AlarmKO
//
//  Created by Jeremy Lumban Toruan on 02/06/25.
//

import Foundation
import WatchConnectivity

class PhoneConnectivityManager: NSObject, WCSessionDelegate, ObservableObject {
    static let shared = PhoneConnectivityManager()
    
    @Published var bpm: Double = 0.0
    
    final let TAG = "PhoneConnectivityManager"
    
    override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
            print("Session supported")
        }
    }
    
    func sendAlarmTrigger() {
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(["alarm": "trigger"], replyHandler: nil, errorHandler: { error in
                print("Error sending message: \(error)")
            })
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        switch activationState {
        case .activated:
            print("\(TAG): WatchConnectivity session activated.")
        case .notActivated:
            print("\(TAG): WatchConnectivity session not activated.")
        case .inactive:
            print("\(TAG): WatchConnectivity session is inactive.")
        @unknown default:
            print("\(TAG): Unkown WatchConnectivity session state.")
        }
        
        if let error = error {
            print("\(TAG): Activation Error, \(error.localizedDescription)")
        }
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        print("\(applicationContext)")
        if let _bpm = applicationContext["heart rate"] as? Double {
            print("\(TAG) Heart rate received, \(bpm) BPM")
            DispatchQueue.main.async {
                self.bpm = _bpm
                
            }
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("Session inactive")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("Session deactivate")
    }
}
