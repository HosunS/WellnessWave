//
//  Dashboardview.swift
//  WellnessWave
//
//  Created by Ho sun Song on 2/6/24.
//
import SwiftUI

struct DashboardView: View {
    @State private var isShowingUserInputView = false
    @State private var caloriesBurned: Double = 0
    @State private var stepsTaken: Double = 0
    
    private var healthStore: HealthStore = HealthStore()
    
    var body: some View {
        
        TabView {
            NavigationView {
                VStack{
                    Text("Calories Burned Today: \(caloriesBurned, specifier: "%.2f")")
                    Text("Steps for today: \(stepsTaken, specifier:"%.0f")")
                }
                    .onAppear {
                        healthStore.requestAuthorization { authorized in
                                if authorized {
                                    healthStore.queryCaloriesBurned { calories, error in
                                        if let calories = calories {
                                            self.caloriesBurned = calories
                                        } else {
                                            print("Error querying calories burned")
                                        }
                                    }
                                    
                                    healthStore.queryStepsForToday{steps in
                                        self.stepsTaken = steps
                                    }
                                    
                                } else {
                                    print("HealthKit authorization was denied.")
                                }
                            }
                    }
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
