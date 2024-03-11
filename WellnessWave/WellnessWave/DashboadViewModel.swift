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

class DashboardViewModel: ObservableObject {
    @Published var caloriesBurned: Double = 0
    @Published var stepsTaken: Double = 0
    @Published var username: String = ""
    @Published var caloriesBurnedGoal: Double = 0
    @Published var workoutGoal: Double = 0
    //trying to keep track of weekly calories burned..
    @Published var actualweeklyCaloriesBurned: Double = 0
    @Published var weeklyCaloriesBurnedGoal: Double = 0
    private var healthStore = HealthStore()
    private var databaseRef = Database.database().reference()
    
    
    // don't have to use this.
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
        //fetch username
        let userRef = databaseRef.child("users").child(currentUser.uid)
        
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
