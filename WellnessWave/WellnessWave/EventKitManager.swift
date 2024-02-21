//
//  EventKitManager.swift
//  WellnessWave
//
//  Created by Ho sun Song on 2/20/24.
//

import Foundation
import EventKit
import FirebaseDatabase

class EventKitManager{
    static let shared = EventKitManager()
    private let eventStore : EKEventStore
    private let databaseRef: DatabaseReference
    
    init() {
        self.eventStore = EKEventStore()
        self.databaseRef = Database.database().reference()
    }
    
    // function to request access to the Event Store for Calendar data
    func requestCalendarAccess(completion: @escaping (Bool, Error?) -> Void) {
        eventStore.requestFullAccessToEvents { accessGranted, error in
            DispatchQueue.main.async {
                completion(accessGranted, error)
            }
        }
    }
    
    func fetchEventsForToday(completion: @escaping ([EKEvent]?) -> Void) {
        let calendars = eventStore.calendars(for: .event)
        let startDate = Calendar.current.startOfDay(for: Date())
        let endDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate)!
        
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: calendars)
        let events = eventStore.events(matching: predicate)
        
        DispatchQueue.main.async {
            completion(events)
        }
    }
    
    func storeEventsInFirebase(forUser userId: String, events: [EKEvent]) {
        let userEventsRef = Database.database().reference().child("users").child(userId).child("events")
        
        for event in events {
            let eventDict: [String: Any] = [
                //datatypes from eventkit to store
                "title": event.title!,
                "startDate": event.startDate.description,
                "endDate": event.endDate.description
                
            ]
            userEventsRef.childByAutoId().setValue(eventDict)
        }
    }
    
}

