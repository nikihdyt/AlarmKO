//
//  HealthManager.swift
//  AlarmKO
//
//  Created by Jeremy Lumban Toruan on 02/06/25.
//

import Foundation
import HealthKit

class HealthManager: ObservableObject {
    
    private let healthStore = HKHealthStore()
    
    @Published var heartRate: Double = 0.0
    @Published var sleepDuration: Double = 0.0
    
    final let TAG = "HealthManager"
    
    
    func requestAuhtorization() {
        let heartRateType = HKQuantityType(.heartRate)
        let sleepType = HKCategoryType(.sleepAnalysis)
        let workoutType = HKQuantityType.workoutType()
        
        let typesToRead: Set = [heartRateType, sleepType, workoutType]
        
        
        healthStore.requestAuthorization(toShare: [], read: typesToRead) { success, error in
            if success {
                print("\(self.TAG): HealthKit authorized")
            } else if let error = error {
                print("\(self.TAG): HealthKit error: \(error.localizedDescription)")
            }
        }
    }
    
    func fetchRecentHeartRate() {
        let heartRateType = HKQuantityType(.heartRate)
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        let queryLive = HKObserverQuery(sampleType: heartRateType, predicate: nil) { _, completionHandler, error in
            
            let query = HKSampleQuery(sampleType: heartRateType, predicate: nil, limit: 1, sortDescriptors: [sort]) { _, samples, _ in
                guard let sample = samples?.first as? HKQuantitySample else { return }
                let bpm = sample.quantity.doubleValue(for: .init(from: "count/min"))
                print("❤️ Latest heart rate: \(bpm) BPM")
                DispatchQueue.main.async {
                    self.heartRate = bpm
                    WatchConnectivityManager.shared.sendHeartRateToPhone(bpm)
                }
            }
            
            self.healthStore.execute(query)
            
            print("Success query")
            completionHandler()
        }

        healthStore.execute(queryLive)
    
    }
    
    
    func fetchLastSleepDuration() {
        let sleepType = HKCategoryType(.sleepAnalysis)
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        let query = HKSampleQuery(sampleType: sleepType, predicate: nil, limit: 1, sortDescriptors: [sort]) { _, samples, _ in
            guard let sample = samples?.first as? HKCategorySample else { return }
            
            let sleepDuration = sample.endDate.timeIntervalSince(sample.startDate) / 3600
            
            DispatchQueue.main.async {
                self.sleepDuration = sleepDuration
            }
        }
        
        healthStore.execute(query)
    }
}
