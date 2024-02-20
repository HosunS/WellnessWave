//
//  DashboadViewModel.swift
//  WellnessWave
//
//  Created by Ho sun Song on 2/20/24.
//

import Combine
import FirebaseAuth
import FirebaseDatabase
import SwiftUI

class DashboardViewModel: ObservableObject {
    @Published var caloriesBurned: Double = 0
    @Published var stepsTaken: Double = 0
    
    @Published var username: String = ""
    
    @Published var caloriesBurnedGoal: Double = 0
    @Published var workoutGoal: Double = 0
    
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
        
        //fetch calories goal
            userRef.child("dailyCalorieBurnedGoal").observeSingleEvent(of: .value, with: { snapshot in
            DispatchQueue.main.async {
                if let burngoal = snapshot.value as? Double {
                    self.caloriesBurnedGoal = burngoal
                }
            }
        })
        //fetch weekly workout goal
            userRef.child("weeklyWorkoutGoal").observeSingleEvent(of: .value, with: { snapshot in
            DispatchQueue.main.async {
                if let workoutGoal = snapshot.value as? Double {
                    self.workoutGoal = workoutGoal
                }
            }
        })
        // healthstore authorization to pull calories burned and step goal from healthstore
        healthStore.requestAuthorization { [weak self] _ in
            self?.healthStore.queryCaloriesBurned { calories in
                DispatchQueue.main.async {
                    self?.caloriesBurned = calories
                    userRef.child("currentCaloriesBurned").setValue(calories)
                }
            }
            self?.healthStore.queryStepsForToday { steps in
                DispatchQueue.main.async {
                    self?.stepsTaken = steps
                    userRef.child("stepsTakenToday").setValue(steps)
                }
            }
        }
    }
    

}
