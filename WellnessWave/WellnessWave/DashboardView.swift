//
//  Dashboardview.swift
//  WellnessWave
//
//  Created by Ho sun Song on 2/6/24.
//
import SwiftUI
import HealthKit
import HealthKitUI

struct DashboardView: View {
    @State private var isShowingUserInputView = false
    @ObservedObject private var viewModel = DashboardViewModel()
    var summary = HKActivitySummary()
    
    var body: some View {
        TabView {
            NavigationView {
                ZStack{
                    Color.black.edgesIgnoringSafeArea(.top)

                VStack {
                    ZStack {
                        ActivityRingView(progress: viewModel.caloriesBurned, goal: viewModel.caloriesBurnedGoal, color: .red)
                            .frame(width: 150, height: 150)
                            .padding()
                        ActivityRingView(progress: viewModel.stepsTaken, goal: 10000, color: .blue) // Example step goal
                            .frame(width: 130, height: 130)
                    }
                    Text("Calories Burned Today: \(viewModel.caloriesBurned, specifier: "%.2f") / \(viewModel.caloriesBurnedGoal, specifier: "%.2f")")
                        .foregroundColor(.red)
                    Text("Steps for today: \(viewModel.stepsTaken, specifier:"%.0f")")
                }
                .onAppear {
                    viewModel.onAppear()
                }
                }
                
                .navigationTitle("Hello \(viewModel.username)!")
                .font(.system(size: 20))
                .foregroundColor(.blue)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            isShowingUserInputView = true
                        }) {
                            Image(systemName: "gearshape.fill")
                        }
                    }
                }
            }
            .tabItem {
                Label("Dashboard", systemImage: "house")
            }
            
            NavigationView {
                SleepView()
                    .navigationTitle("Sleep")
            }
            .tabItem {
                Label("Sleep", systemImage: "moon.zzz")
            }
            
            NavigationView {
                ExerciseView()
                    .navigationTitle("Exercise")
            }
            .tabItem {
                Label("Exercise", systemImage: "heart.fill")
            }

            NavigationView {
                HydrationView()
                    .navigationTitle("Hydration")
            }
            .tabItem{
                Label("Hydration", systemImage: "drop.fill")
            }
        }
        .sheet(isPresented: $isShowingUserInputView) {
            UserInputView(isPresented: $isShowingUserInputView)
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
