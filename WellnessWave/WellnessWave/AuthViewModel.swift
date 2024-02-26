//
//  AuthViewModel.swift
//  WellnessWave
//
//  Created by Ho sun Song on 2/6/24.
//

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseDatabase
// handels the authentications

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
    private let databaseRef: DatabaseReference
    
    init() {
        // Check authentication state when the app starts
        self.isAuthenticated = Auth.auth().currentUser != nil
        self.databaseRef = Database.database().reference()
    }
    
    
    
    func logIn(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error as NSError? {
                print("Error occurred during sign up: \(error.localizedDescription)")
            } else {
                print("User signed up successfully")
                self.isAuthenticated = true
                // Handle successful login, for example, by updating the view or transitioning to another part of your app
            }
        }
    }


    func signUp(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("Error occurred during sign up: \(error.localizedDescription)")
            } else if let authResult = authResult{
                print("User signed up successfully")
                self.isAuthenticated = true
                // add whatever data we want to initialize the user's database with, will have users enter this information in userinputview
                let userData: [String:Any] = [
                    "email" : email,
                    "name" : "",
                    "height" : 0,
                    "weight" : 0,
                    "weeklyWorkoutGoal":0,
                    "dailyCalorieBurnedGoal":0,
                    "lastLoggedIn":0,
                    "waterLevel":0
                    
                ]
                self.saveUserData(uid: authResult.user.uid, userData: userData)
                
            }
        }
    }
    
    private func saveUserData(uid: String, userData: [String: Any]) {
        databaseRef.child("users").child(uid).setValue(userData) { error, _ in
            if let error = error {
                print("Error saving user data: \(error.localizedDescription)")
            } else {
                print("User data saved successfully")
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.isAuthenticated = false
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}
