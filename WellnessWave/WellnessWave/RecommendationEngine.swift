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
    var eventsForSelectedDate: [Event] = []
    @State var recommendDate: String = ""
    
    func fetchSelectedDate() {
        
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
                    print(selectedDate)
                }
            }
        })
        //fetch the selected duration
        userRef.child("selectedDuration").observeSingleEvent(of: .value, with: { snapshot in
            DispatchQueue.main.async {
                if let selectedDuration = snapshot.value as? Int {
                    self.selectedDuration = selectedDuration
                    print(selectedDuration)
                }
            }
        })
        
    }
    
    func fetchEvents(completion: @escaping () -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            print("No current user found")
            completion()
            return
        }
        
        let eventsRef = databaseRef.child("users").child(currentUser.uid).child("events").child(self.selectedDate)
        
        eventsRef.observeSingleEvent(of: .value, with: { snapshot in
            var fetchedEvents: [Event] = []
            
            for child in snapshot.children {
                guard let childSnapshot = child as? DataSnapshot,
                      let eventDict = childSnapshot.value as? [String: Any] else { continue }
                
                if let event = Event(dictionary: eventDict) {
                    fetchedEvents.append(event)
                }
            }
            
            DispatchQueue.main.async {
                self.eventsForSelectedDate = fetchedEvents
                print("Events for selected date updated.")
                completion()
            }
        }, withCancel: { error in
            print(error.localizedDescription)
            DispatchQueue.main.async {
                completion()
            }
        })
    }
    
    func calculateFreeTimeSlots(from events: [Event], on day: Date) -> [DateInterval] {
        var freeTimeSlots: [DateInterval] = []
        
        let calendar = Calendar.current
//        let startOfDay = calendar.startOfDay(for: day)
        let workdayStartTime = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: day)!
        let workdayEndTime = calendar.date(bySettingHour: 22, minute: 0, second: 0, of: day)!
        
        var lastEventEnd: Date = workdayStartTime
        
        for event in events.sorted(by: { $0.startDate < $1.startDate }) {
            if event.endDate <= workdayStartTime || event.startDate >= workdayEndTime { continue }
            
            let eventStart = max(event.startDate, workdayStartTime)
            let eventEnd = min(event.endDate, workdayEndTime)
            
            if eventStart > lastEventEnd {
                freeTimeSlots.append(DateInterval(start: lastEventEnd, end: eventStart))
            }
            lastEventEnd = eventEnd
        }
        
        if lastEventEnd < workdayEndTime {
            freeTimeSlots.append(DateInterval(start: lastEventEnd, end: workdayEndTime))
        }
        
        return freeTimeSlots
    }
    
    // returning the earliest available time for now
    func calculateBestWorkoutTimeUsingFreeSlots(freeTimeSlots: [DateInterval], durationMinutes: Int) -> String {
        let workoutDurationInSeconds = Double(durationMinutes) * 60
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        
        for slot in freeTimeSlots.sorted(by: { $0.start < $1.start }) {
            if slot.duration >= workoutDurationInSeconds {
                return "Best Time: \(dateFormatter.string(from: slot.start))"
            }
        }
        
        return "No suitable time found within preferred hours."
    }
    
    
    
    func recommendWorkout(completion: @escaping (String) -> Void) {
        fetchSelectedDate()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else { return }
            
            // ensure selectedDate is not empty
            guard !self.selectedDate.isEmpty else {
                completion("Selected date is not set.")
                return
            }
            
            // fetch events for this date.
            self.fetchEvents {
                // after fetching events from realtimedb, they are stored in self.eventsForSelectedDate.
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyyMMdd"
                guard let date = dateFormatter.date(from: self.selectedDate) else {
                    completion("Error parsing selected date.")
                    return
                }
                
                print("Events for selected date (\(self.selectedDate)):")
                self.eventsForSelectedDate.forEach {event in
                    print(event) // just a check to see if the events are properly stored
                }
                
                // calculate free time slots from these events.
                let freeTimeSlots = self.calculateFreeTimeSlots(from: self.eventsForSelectedDate, on: date)
                
                // use the free time slots to recommend a workout time.
                let recommendedTime = self.calculateBestWorkoutTimeUsingFreeSlots(freeTimeSlots: freeTimeSlots, durationMinutes: self.selectedDuration)
                completion(recommendedTime)
            }
        }
    }
    
    
    
    
}

