//
//  UserInputView.swift
//  WellnessWave
//
//  Created by Ho sun Song on 2/7/24.
//
import SwiftUI
import FirebaseDatabase
import FirebaseAuth

struct UserInputView: View {
    @Binding var isPresented: Bool
    @ObservedObject var viewModel: DashboardViewModel

    @State private var name: String = ""
    @State private var height: Double = 0
    @State private var weight: Double = 0
    @State private var weeklyWorkoutGoal: Int = 0
    @State private var dailyCalorieBurnedGoal: Int = 0
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    TextField("Name", text: $name)
                    
                    Text("Height: \(formatHeight(height))")
                    Slider(value: $height, in: 0...7, step: 0.01)
                    Text("Weight: \(String(format: "%.1f", weight)) lbs")
                    Slider(value: $weight, in: 0...400, step: 0.1)
                }
                Section(header: Text("Fitness Goals")) {
                    Stepper(value: $weeklyWorkoutGoal, in: 0...600, step: 10) {
                        Text("Weekly Workout Time: \(formatWorkoutTime(weeklyWorkoutGoal))")
                    }
                    Stepper(value: $dailyCalorieBurnedGoal, in: 0...5000, step: 100) {
                        Text("Daily Calorie Burn Goal: \(dailyCalorieBurnedGoal) kcal")
                    }
                }
                Button(action: saveUserData) {
                    Text("Save")
                }
            }
            .navigationTitle("User Input")
        }
        .onAppear {
            // Fetch and populate existing user data when the view appears
            fetchUserData()
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func fetchUserData() {
        guard let userID = Auth.auth().currentUser?.uid else {
            // User is not authenticated, unable to fetch data
            return
        }
        
        let databaseRef = Database.database().reference()
        databaseRef.child("users").child(userID).observeSingleEvent(of: .value) { snapshot in
            guard let userData = snapshot.value as? [String: Any] else {
                // No user data found in database
                return
            }
            
            // Populate input fields with existing user data
            name = userData["name"] as? String ?? ""
            height = userData["height"] as? Double ?? 0
            weight = userData["weight"] as? Double ?? 0
            weeklyWorkoutGoal = userData["weeklyWorkoutGoal"] as? Int ?? 0
            dailyCalorieBurnedGoal = userData["dailyCalorieBurnedGoal"] as? Int ?? 0
        }
    }
    
    private func saveUserData() {
        guard let userID = Auth.auth().currentUser?.uid else {
            // User is not authenticated, unable to save data
            return
        }
        
        let userData: [String: Any] = [
            "name": name,
            "height": height,
            "weight": weight,
            "weeklyWorkoutGoal": weeklyWorkoutGoal,
            "dailyCalorieBurnedGoal": dailyCalorieBurnedGoal
        ]
        
        let databaseRef = Database.database().reference()
        databaseRef.child("users").child(userID).updateChildValues(userData) { error, _ in
            if let error = error {
                print("Error saving user data: \(error.localizedDescription)")
            } else {
                print("User data saved successfully")
                // Dismiss the UserInputView after saving data
                self.viewModel.fetchUserDataAndGoals()
                isPresented = false
            }
        }
    }
    
    private func formatWorkoutTime(_ minutes: Int) -> String {
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        if hours > 0 {
            return "\(hours) hr \(remainingMinutes) min"
        } else {
            return "\(remainingMinutes) min"
        }
    }
    
    private func formatHeight(_ height: Double) -> String {
        let feet = Int(height)
        let inches = Int((height - Double(feet)) * 12)
        return "\(feet) ft \(inches) in"
    }
}

struct UserInputView_Previews: PreviewProvider {
    static var previews: some View {
        UserInputView(isPresented: .constant(true), viewModel:DashboardViewModel() )
    }
}
