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

class HealthStore{
    private let healthStore: HKHealthStore
    private let databaseRef: DatabaseReference
    
    init(){
        
        self.healthStore = HKHealthStore()
        self.databaseRef = Database.database().reference()
        
        requestAuthorization()
    }
    
    private func requestAuthorization(){
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit is not available on this device")
            return
        }
        let readTypes: Set<HKObjectType> = [
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .dietaryWater)!,
            HKObjectType.workoutType()
        ]
                
                // Request authorization to read data
        healthStore.requestAuthorization(toShare: nil, read: readTypes) { (success, error) in
            if !success {
                // Handle errors or lack of permissions here
                print("Permission was not granted for HealthKit data.")
            }
        }
    }
    
    
}


