//
//  HomepageView.swift
//  WellnessWave
//
//  Created by Ho sun Song on 2/6/24.
//

import Foundation
import SwiftUI
import HealthKit
import EventKit

struct HomePageView: View {
    // Add properties for health and calendar data here
    
    @EnvironmentObject private var authViewModel: AuthViewModel
    var body: some View {
        NavigationView {
            VStack {
                Text("Welcome to Your Fitness Dashboard")
                    .font(.title)
                    .padding()
                
                // placeholder for health data summary
                VStack(alignment: .leading) {
                    Text("Health Summary")
                        .font(.headline)
                }
                .padding()
                
                // placeholder for workout recommendation
                VStack(alignment: .leading) {
                    Text("Recommended Workout Time")
                        .font(.headline)
    
                }
                .padding()
                
                Button("Logout") {
                    authViewModel.signOut()
                }
                
                Spacer()
            }
            .navigationBarTitle("Home", displayMode: .inline)
        }
    }
}

struct HomePageView_Previews: PreviewProvider {
    static var previews: some View {
        HomePageView()
    }
}
