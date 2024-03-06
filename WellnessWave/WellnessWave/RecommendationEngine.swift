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
    
    func recommendWorkout(completion: @escaping (String) -> Void) {
        print("recommendWorkout called")

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
}

