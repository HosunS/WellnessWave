//
//  HealthStore.swift
//  WellnessWave
//
//  Created by Ho sun Song on 1/29/24.
//

import Foundation
import HealthKit
import FirebaseAuth
import FirebaseDatabase

class HealthStore {
    private let healthStore: HKHealthStore
    private let databaseRef: DatabaseReference
    
    init() {
        self.healthStore = HKHealthStore()
        self.databaseRef = Database.database().reference()
    }
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit is not available on this device")
            completion(false)
            return
        }
        
        let readTypes: Set<HKObjectType> = [
            //add datatypes to pull from healthkit
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
//            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        ]
        
        
        
        healthStore.requestAuthorization(toShare: nil, read: readTypes) { success, error in
            DispatchQueue.main.async {
                completion(success)
            }
        }
    }
    
    func queryCaloriesBurned(completion: @escaping (Double?, Error?) -> Void) {
        guard let calorieType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
            completion(nil, NSError(domain: "HealthKit", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to create calorie type"]))
            return
        }
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: calorieType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            DispatchQueue.main.async {
                if let sum = result?.sumQuantity() {
                    let calories = sum.doubleValue(for: HKUnit.kilocalorie())
                    completion(calories, nil)
                } else {
                    completion(nil, error)
                }
            }
        }
        
        healthStore.execute(query)
    }
    
    func queryStepsForToday(completion: @escaping (Double) -> Void) {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            completion(0)
            return
        }

        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)

        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            DispatchQueue.main.async {
                let stepCount = result?.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0
                completion(stepCount)
            }
        }

        healthStore.execute(query)
    }
    

}
