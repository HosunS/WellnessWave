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
    }
    

}

