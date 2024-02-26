//
//  HydrationViewModel.swift
//  WellnessWave
//
//  Created by Alejandro Becerra on 2/20/24.
//

import Combine
import FirebaseAuth
import FirebaseDatabase
import SwiftUI

class HydrationViewModel: ObservableObject {
    
    @Published var username: String = ""
    @Published var weight: Double = 0
    @Published var lastLoggedIn: Date = Date()
    @Published var waterLevel: CGFloat = 0
    
    private var healthStore = HealthStore()
    private var databaseRef = Database.database().reference()
    
    func onAppear() {
        guard let currentUser = Auth.auth().currentUser else {
            print("No current user found")
            return
        }
        //fetch username
        let userRef = databaseRef.child("users").child(currentUser.uid)
        
            userRef.child("name").observeSingleEvent(of: .value, with: { snapshot in
            DispatchQueue.main.async {
                if let username = snapshot.value as? String {
                    self.username = username
                }
            }
        })
        
        //fetch weight
        userRef.child("weight").observeSingleEvent(of: .value, with: { snapshot in
            DispatchQueue.main.async {
                if let weight = snapshot.value as? Double {
                    self.weight = weight
                }
            }
        })
        
        //reset waterLevel if new day, otherwise fetch waterLevel
        userRef.child("lastLoggedIn").observeSingleEvent(of: .value, with: { snapshot in
            DispatchQueue.main.async {
                if let lastLoggedIn = snapshot.value as? Int {
                    let calendar = Calendar.current
                    let currentDay = calendar.component(.weekday, from:self.lastLoggedIn)
                    //compare current day versus day of lastLoggedIn
                    if currentDay != lastLoggedIn {
                        userRef.child("waterLevel").setValue(0)
                        userRef.child("lastLoggedIn").setValue(currentDay)
                    }
                    //fetch waterLevel
                    else {
                        userRef.child("waterLevel").observeSingleEvent(of: .value, with: { snapshot in
                            DispatchQueue.main.async {
                                if let waterLevel = snapshot.value as? Double {
                                    self.waterLevel = waterLevel
                                }
                            }
                        })
                    }
                }
            }
        })
    }
    //save waterLevel when button is clicked in HydrationView
    func saveWater(waterLevel: CGFloat) {
        guard let currentUser = Auth.auth().currentUser else {
            print("No current user found")
            return
        }
        let userRef = databaseRef.child("users").child(currentUser.uid)
        
        userRef.child("waterLevel").setValue(waterLevel)
    }
    

}

