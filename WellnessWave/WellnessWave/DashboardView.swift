//
//  Dashboardview.swift
//  WellnessWave
//
//  Created by Ho sun Song on 2/6/24.
//
import SwiftUI

struct DashboardView: View {
    @State private var isShowingUserInputView = false

    var body: some View {
        TabView {
            NavigationView {
                Text("Dashboard")
                    .navigationTitle("Dashboard")
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
