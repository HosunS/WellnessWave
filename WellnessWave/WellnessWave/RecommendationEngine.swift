//
//  RecommendationEngine.swift
//  WellnessWave
//
//  Created by Ho sun Song on 3/3/24.
//

import FirebaseDatabase
import Foundation
import FirebaseAuth
import UIKit
import SwiftUI
import CoreLocation
import EventKit

class RecommendationEngine {
    private var databaseRef = Database.database().reference()
    @Published var selectedDate: String = ""
    @Published var selectedDuration: Int = 0
    
    func fetchSelectedDate(completion: @escaping (Date?) -> Void) {
        guard let currentUser = Auth.auth().currentUser else{
            print("No current user")
            return
        }
        
        let userRef = databaseRef.child("users").child(currentUser.uid)
        
        //fetch the selected date
        userRef.child("selectedDate").observeSingleEvent(of: .value, with: { snapshot in
        DispatchQueue.main.async {
            if let selectedDate = snapshot.value as? String {
                self.selectedDate = selectedDate
            }
        }
    })
        //fetch the selected duration
        userRef.child("selectedDuration").observeSingleEvent(of: .value, with: { snapshot in
        DispatchQueue.main.async {
            if let selectedDuration = snapshot.value as? Int {
                self.selectedDuration = selectedDuration
            }
        }
    })
        
    }
    
    func fetchEvents(forDate date: String, completion: @escaping ([Event]) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            print("No current user found")
            return
        }
        
        let dateKeyPrefix = date
        
        let eventsRef = databaseRef.child("users").child(currentUser.uid).child("events")
        eventsRef.observeSingleEvent(of: .value) { snapshot in
            var events = [Event]()
            
            for child in snapshot.children.allObjects as? [DataSnapshot] ?? [] {
                let eventKey = child.key
                // check if the eventKey starts with the selectedDate
                if eventKey.hasPrefix(dateKeyPrefix) {
                    if let eventDict = child.value as? [String: Any] {
                        // use the dictionary to initialize an event object
                        if let event = Event(dictionary: eventDict) {
                            events.append(event)
                        }
                    }
                }
            }
            DispatchQueue.main.async {
                completion(events)
            }
        }
    }
    
    func recommendWorkout(selectedDate: Date, hours: Int, minutes: Int, completion: @escaping (String) -> Void) {
        print("recommendWorkout called")
        
        
        (for: selectedDate) { freeTimeSlots in
                    let recommendedTime = self.calculateBestWorkoutTime(freeTimeSlots: freeTimeSlots, hours: hours, minutes: minutes)
                    completion(recommendedTime)
                }
        
        fetchSelectedDate { [weak self] selectedDate in
            guard let self = self, let date = selectedDate else {
                print("No selected date found.")
                completion("No date selected")
                return
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMdd"
            let selectedDateString = dateFormatter.string(from: date)
            
            self.fetchEvents(forDate: selectedDateString) { events in
                print("found some asdf")
                // apply logic here
                let recommendedTime = "07:00" // placeholder, replace with actual calculation
                completion(recommendedTime)
            }
        }
    }
    
    private func fetchFreeTimeSlots(for date: Date, completion: @escaping ([DateInterval]) -> Void) {
            let eventStore = EKEventStore()
            eventStore.requestFullAccessToEvents { granted, error in
                guard granted && error == nil else {
                    print("Access denied or error occurred: \(String(describing: error))")
                    completion([])
                    return
                }

                let calendars = eventStore.calendars(for: .event)
                let startDate = Calendar.current.startOfDay(for: date)
                let endDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate)!
                let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: calendars)
                let events = eventStore.events(matching: predicate).sorted { $0.startDate < $1.startDate }

                var freeTimeSlots: [DateInterval] = []
                var lastEventEnd = startDate

                for event in events {
                    if event.startDate > lastEventEnd {
                        freeTimeSlots.append(DateInterval(start: lastEventEnd, end: event.startDate))
                    }
                    lastEventEnd = max(lastEventEnd, event.endDate)
                }

                if lastEventEnd < endDate {
                    freeTimeSlots.append(DateInterval(start: lastEventEnd, end: endDate))
                }

                completion(freeTimeSlots)
            }
        }

        private func calculateBestWorkoutTime(freeTimeSlots: [DateInterval], hours: Int, minutes: Int) -> String {
            // Implement the logic to determine the best workout time
            // This is a placeholder implementation
            if let suitableSlot = freeTimeSlots.first(where: { $0.duration >= Double(hours * 60 + minutes) * 60 }) {
                return "Best Time: \(suitableSlot.start)"
            } else {
                return "No suitable time found."
            }
        }
}

