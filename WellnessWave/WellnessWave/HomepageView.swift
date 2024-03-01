//
//  HomepageView.swift
//  WellnessWave
//
//  Created by Ho sun Song on 2/6/24.
//
// Intermediate page to send user to either dashboard or Input data page
import Foundation
import SwiftUI
import HealthKit
import EventKit
import FirebaseAuth

struct HomePageView: View {
    @State private var hasUserData: Bool = false
    @State private var loggedout: Bool = false
    @EnvironmentObject private var authViewModel: AuthViewModel
    @State private var dashboardViewModel = DashboardViewModel()


    var body: some View {
            VStack {
                if hasUserData {
                    DashboardView()
                } else {
                    UserInputView(isPresented: .constant(false), viewModel: dashboardViewModel)
                }
                
                Spacer()
                Button("Logout") {
                    authViewModel.signOut()
                }
                Spacer()
            }
            .navigationBarTitle("Home", displayMode: .inline)
            .onAppear {
                // Check user data when the view appears
                checkUserData()
            }
            .onReceive(authViewModel.$isAuthenticated) { isAuthenticated in
                if !isAuthenticated {
                    // User is not authenticated, navigate to login/signup view
                    loggedout = true
                }
            }
            .fullScreenCover(isPresented: $loggedout) {
                // Navigate to the welcome view when logged out
                WelcomeView()
            }
    }
    
    private func checkUserData() {
        // get the current user from Auth
        guard let userID = Auth.auth().currentUser?.uid else {
            // User is not authenticated
            return
        }
        // check this user in realtimedatabase
        FirebaseService.shared.getUserData(userID: userID) { result in
            switch result {
            case .success(let userData):
                if let name = userData["name"] as? String, !name.isEmpty {
                    print("User name: \(name)")
                    // Assuming the user has a name, set hasUserData to true
                    hasUserData = true
                } else {
                    print("User does not have a name")
                    hasUserData = false
                }
            case .failure(let error):
                print("Error retrieving user data: \(error.localizedDescription)")
            }
        }
    }
}

struct HomePageView_Previews: PreviewProvider {
    static var previews: some View {
        HomePageView().environmentObject(AuthViewModel())
    }
}
