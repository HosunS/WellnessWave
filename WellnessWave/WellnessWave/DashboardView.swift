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
    @ObservedObject private var viewModelHydration = HydrationViewModel()
    @State private var isFirstTime = true
    @State private var selectedTab = 0
    @State private var showTransitionView = true

    var summary = HKActivitySummary()
    
    var body: some View {
        ZStack{
            TabView(selection: $selectedTab) {
                NavigationView {
                    ZStack{
                        Color.black.edgesIgnoringSafeArea(.top)
                        VStack {
                            Text("\(viewModel.userlacking)")
                                .bold()
                                .foregroundColor(.white)
                            ZStack {
                                ActivityRingView(progress: viewModel.actualweeklyCaloriesBurned, goal: viewModel.weeklyCaloriesBurnedGoal, color: .red)
                                    .frame(width: 160, height: 180)
                                    .padding()
                                ActivityRingView(progress: viewModel.hydrationSum, goal: viewModel.recommended, color: .blue) // Example step goal
                                    .frame(width: 140, height: 150)
                                Text("Total Score")
                                    .bold()
                                    .foregroundColor(.white)
                                    .scenePadding(.bottom)
                                    .scenePadding(.bottom)
                                    .scenePadding(.bottom)
                                Text("\(viewModel.lifeStyleScore, specifier: "%.f") / 100")
                                    .bold()
                                    .foregroundColor(.white)
                                    .scenePadding(.top)
                            }
                            Text("Calories Burned Weekly: \(viewModel.actualweeklyCaloriesBurned, specifier: "%.2f") / \(viewModel.weeklyCaloriesBurnedGoal, specifier: "%.2f")")
                                .foregroundColor(.red)
                            Text("Hydration Weekly Meter: \(viewModel.hydrationSum, specifier: "%.2f") / \(viewModel.recommended, specifier: "%.f")")
                        }
                        .onAppear {
                            viewModel.fetchUserDataAndGoals()
                            viewModel.fetchAndCalculateTotalCalories()
                            viewModel.fetchLifeStyleScore()
                            viewModel.updateLifeStyleScore()
                            viewModel.userRecommend()
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
                .tag(0)
                
                NavigationView {
                    SleepView()
                        .navigationTitle("Sleep")
                }
                .tabItem {
                    Label("Sleep", systemImage: "moon.zzz")
                }
                .tag(1)
                
                NavigationView {
                    ExerciseView()
                        .navigationTitle("Exercise")
                }
                .tabItem {
                    Label("Exercise", systemImage: "heart.fill")
                }
                .tag(2)
                
                NavigationView {
                    HydrationView()
                        .navigationTitle("Hydration")
                }
                .tabItem{
                    Label("Hydration", systemImage: "drop.fill")
                }
                .tag(3)
            }
            if showTransitionView{
                TransitionView()
                    .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
                    .zIndex(1)
            }
        }
        .onAppear {
            if isFirstTime {
                showTransitionView = true // loadingscreen
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.selectedTab = 1 // switch to sleep
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.selectedTab = 0 //switch back to dash
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.showTransitionView = false //hide?
                            self.isFirstTime = false // Ensure this runs only once per app session
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $isShowingUserInputView) {
            UserInputView(isPresented: $isShowingUserInputView, viewModel: viewModel)
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
