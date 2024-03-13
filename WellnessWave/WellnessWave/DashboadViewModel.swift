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
import EventKit
import HealthKit
import HealthKitUI

class DashboardViewModel: ObservableObject {
    @Published var caloriesBurned: Double = 0
    @Published var stepsTaken: Double = 0
    @Published var username: String = ""
    @Published var caloriesBurnedGoal: Double = 0
    @Published var workoutGoal: Double = 0
    
    //trying to keep track of weekly calories burned..
    @Published var actualweeklyCaloriesBurned: Double = 0
    @Published var weeklyCaloriesBurnedGoal: Double = 0
    
    //scores for hydration, exercise, and sleep
    @Published var hydrationScore: Double = 0
    @Published var exerciseScore: Double = 0
    @Published var sleepScore: Double = 0
    @Published var lifeStyleScore: Double = 0
    
    //bool to track lowest score to provide improvement recommendations
    @Published var hydrationLowest: Bool = false
    @Published var exerciseLowest: Bool = false
    @Published var lifeStyleSCore: Bool = false
    
    @Published var userWeight: Double = 0.0
    @Published var recommended: Double = 0
    @Published var hydrationSum: Double = 0
    @Published var sleepSum: Double = 0
    
    @Published var userlacking: String = ""
    
    @ObservedObject private var viewModel = HydrationViewModel()
    
    private var healthStore = HealthStore()
    private var databaseRef = Database.database().reference()
    
    func userRecommend(){
        let smallest = min(self.hydrationScore, self.exerciseScore, self.sleepScore)
        if smallest == hydrationScore{
            self.userlacking = "Make sure you drink more water!"
        }
        else if smallest == exerciseScore{
            self.userlacking = "Get more workouts recommended and complete them to increase your lifestyle score!"
        }
        else if smallest == sleepScore{
            self.userlacking = "We recommend not using any electronics for one hour before bed to make sure you can get good sleep!"
        }
    }
    
    //Fetch scores
    func fetchLifeStyleScore() {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            print("No current user found")
            return
        }
        
        let userRef = databaseRef.child("users").child(currentUserID)
        // fetching pastSleepQuality data.
        userRef.child("pastSleepQuality").observeSingleEvent(of: .value, with: { snapshot in
            DispatchQueue.main.async {
                if let pastSleepQuality = snapshot.value as? [Int] {
                    // ensure the array isn't empty to avoid division by zero.
                    guard !pastSleepQuality.isEmpty else {
                        self.sleepScore = 0
                        return
                    }
                    
                    // calculate the sum of the array's elements and then compute the average.
                    let sum = pastSleepQuality.reduce(0, +)
                    self.sleepSum = Double(sum)
                    let average = Double(sum) / Double(pastSleepQuality.count)
                    self.sleepScore = average
                    
                } else {
                    // handle the case where pastSleepQuality doesn't exist or isn't an array of doubles.
                    print("Failed to fetch or parse pastSleepQuality")
                    self.sleepScore = 0
                }
            }
        }) { error in
            print(error.localizedDescription)
            self.sleepScore = 0
        }
        // fetching pastHydrayionQuality data // same as fetching pastSleepQuality
        userRef.child("pastHydrationQuality").observeSingleEvent(of: .value, with: { snapshot in
            DispatchQueue.main.async {
                if let pastHydrationQuality = snapshot.value as? [Double] {
                    guard !pastHydrationQuality.isEmpty else {
                        self.hydrationScore = 0
                        return
                    }
                    let sum = pastHydrationQuality.reduce(0, +)
                    self.hydrationSum = sum
                    let average = Double(sum) / Double(pastHydrationQuality.count)
                    self.hydrationScore = average
                    
                } else {
                    print("Failed to fetch or parse pastHydrationQuality")
                    self.hydrationScore = 0
                }
            }
        }) { error in
            print(error.localizedDescription)
            self.hydrationScore = 0
        }
        
        // convert exercise score into a value within 100
        self.exerciseScore = self.actualweeklyCaloriesBurned/self.weeklyCaloriesBurnedGoal
        if self.exerciseScore < 1{
            self.exerciseScore *= 100
        }
        else{
            self.exerciseScore = 100
        }
        print(exerciseScore)
        print(hydrationScore)
        print(sleepScore)
        
        self.updateLifeStyleScore()
    }

    func updateLifeStyleScore() {
        self.lifeStyleScore = (hydrationScore + exerciseScore + sleepScore) / 3
    }
    
    func fetchAndCalculateTotalCalories() {
            guard let currentUserID = Auth.auth().currentUser?.uid else {
                print("No current user found")
                return
            }
            
            databaseRef.child("users").child(currentUserID).child("completedWorkouts").observeSingleEvent(of: .value) { snapshot in
                var totalCalories = 0.0
                for child in snapshot.children {
                    if let childSnapshot = child as? DataSnapshot,
                       let workout = childSnapshot.value as? [String: Any],
                       let calories = workout["burnedCalories"] as? Double {
                        totalCalories += calories
                    }
                }
                DispatchQueue.main.async {
                    self.actualweeklyCaloriesBurned = totalCalories
                }
            }
        }
    
    func fetchUserDataAndGoals() {
        guard let currentUser = Auth.auth().currentUser else {
            print("No current user found")
            return
        }
        let userRef = databaseRef.child("users").child(currentUser.uid)

        //fetch user weight
            userRef.child("weight").observeSingleEvent(of: .value, with: { snapshot in
            DispatchQueue.main.async {
                if let weight = snapshot.value as? Double {
                    self.userWeight = weight
                }
            }
        })
        //fetch username
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
                    self.weeklyCaloriesBurnedGoal = burngoal * 7
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
        self.recommended = self.userWeight * 0.5 * 7
        requestEventAccess()
    }
    
    func requestEventAccess() {
        let eventStore = EKEventStore()
        eventStore.requestFullAccessToEvents { [weak self] granted, error in
            guard granted, error == nil else {
                print("Access to Calendar was denied or there was an error: \(String(describing: error))")
                return
            }
            
            self?.fetchAndStoreEvents(eventStore: eventStore)
        }
    }

    private func fetchAndStoreEvents(eventStore: EKEventStore) {
        let calendars = eventStore.calendars(for: .event)
        let startDate = Date() // Starting from now
        let endDate = Calendar.current.date(byAdding: .day, value: 7, to: startDate)! // Fetching events for the next 7 days
        
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: calendars)
        let events = eventStore.events(matching: predicate).filter { !$0.isAllDay }
        
        guard let currentUser = Auth.auth().currentUser else {
            print("No current user found for storing events")
            return
        }
        
        let userEventsRef = databaseRef.child("users").child(currentUser.uid).child("events")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd" // Format to group events by day
        
        // dictionary to hold events grouped by their day
        var eventsByDay: [String: [[String: Any]]] = [:]
        
        for event in events {
            let eventDayKey = dateFormatter.string(from: event.startDate)
            let eventDict: [String: Any] = [
                "title": event.title ?? "No Title",
                "startDate": event.startDate.description,
                "endDate": event.endDate.description,
                "duration": Int(event.endDate.timeIntervalSince(event.startDate) / 60),
                // additional events if needed
            ]
            
            // append the event dictionary to the array of events for its day, creating the array if necessary
            if var dayEvents = eventsByDay[eventDayKey] {
                dayEvents.append(eventDict)
                eventsByDay[eventDayKey] = dayEvents
            } else {
                eventsByDay[eventDayKey] = [eventDict]
            }
        }
        
        // remove existing events before updating
        userEventsRef.removeValue { error, _ in
            if let error = error {
                print("Error removing existing events: \(error.localizedDescription)")
                return
            }
            
            // store the grouped events in Firebase
            for (dayKey, dayEvents) in eventsByDay {
                userEventsRef.child(dayKey).setValue(dayEvents)
            }
        }
    }

}
