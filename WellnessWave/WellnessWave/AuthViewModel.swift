//
//  AuthViewModel.swift
//  WellnessWave
//
//  Created by Ho sun Song on 2/6/24.
//

import Foundation
import SwiftUI
import FirebaseAuth
// handels the authentications

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = "Login Error"
    
    init() {
        // Check authentication state when the app starts
        self.isAuthenticated = Auth.auth().currentUser != nil
    }
    
    
    
    func logIn(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error as NSError? {
                self.showingAlert = true
                self.alertMessage = error.localizedDescription
                self.alertTitle = "Login Error"
            } else {
                self.showingAlert = true
                self.alertMessage = "You're now logged in!"
                self.alertTitle = "Success"
                self.isAuthenticated = true
                // Handle successful login, for example, by updating the view or transitioning to another part of your app
            }
        }
    }


    func signUp(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("Error occurred during sign up: \(error.localizedDescription)")
            } else {
                print("User signed up successfully")
                self.isAuthenticated = true
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
