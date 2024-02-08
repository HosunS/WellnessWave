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
    }
}


