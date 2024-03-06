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
    
    private var healthStore = HealthStore()
    private var databaseRef = Database.database().reference()
    
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
        let endDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate)! // Fetching events for today
        
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: calendars)
        let events = eventStore.events(matching: predicate)
        
        guard let currentUser = Auth.auth().currentUser else {
            print("No current user found for storing events")
            return
        }
        
        let userEventsRef = databaseRef.child("users").child(currentUser.uid).child("events")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmm" // used to store event name in the format of Year / Month / Day / Hour / Minutes
//        dateFormatter.dateFormat = "yyyyMMdd" // have it match the day in our selected date
        
        let dayOfWeekFormatter = DateFormatter()
        dayOfWeekFormatter.dateFormat = "EEEE" // Format to get the day of the week
        
        userEventsRef.removeValue { error, _ in
            if let error = error {
                print("Error removing existing events: \(error.localizedDescription)")
                return
            }
        }
        
        for event in events {
            // skip all-day events
            if event.isAllDay {
                continue
            }
                 
            let duration = Int(event.endDate.timeIntervalSince(event.startDate) / 60)
            
            let eventKey = dateFormatter.string(from: event.startDate)
    
            let dayOfWeek = dayOfWeekFormatter.string(from: event.startDate)
            
            let eventDict: [String: Any] = [
                "title": event.title ?? "No Title",
                "startDate": event.startDate.description,
                "endDate": event.endDate.description,
                "duration": duration,
                "isAllDay": event.isAllDay, // will always be false for now, but we can also have it not skip the event if its allday
                "dayOfWeek": dayOfWeek
                //can pull and store more data depending on what we need here
            ]
            
            userEventsRef.child(eventKey).setValue(eventDict)
        }
    }
}
