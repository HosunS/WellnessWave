//
//  SleepView.swift
//  WellnessWave
//
//  Created by Ho sun Song on 2/7/24.
//

import SwiftUI
import Foundation
import UserNotifications
import UIKit
import FirebaseAuth
import FirebaseDatabase

struct SleepView: View {
    @State private var bedTime = Date()
    @State private var wakeTime = Date()
    @State private var bedTimePicker = false
    @State private var wakeTimePicker = false
    private var databaseRef = Database.database().reference()
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.top)
            VStack (alignment: .leading){
                Text("Current Alarms: ")
                    .foregroundColor(.white)
                    .font(.largeTitle)
                    
                Divider().background(Color.white)
                
                // bedtime
                Button(action: {
                    bedTimePicker.toggle()
                    scheduleAlarm()
                    saveSleepTimes()
                    
                }) {
                    HStack {
                        Image(systemName: "bed.double")
                            .font(.system(size: 50))
                            .padding()
                            .foregroundColor(.white)

                        Text("Bed Time: \(shortTime(bedTime))")
                            .foregroundColor(.white)
                    }
                }
                
                if bedTimePicker {
                    DatePicker("", selection: $bedTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(WheelDatePickerStyle())
                        .colorInvert()
                }
                
                Divider().background(Color.white)
                
                Button(action: {
                    wakeTimePicker.toggle()
                    scheduleAlarm()
                    saveSleepTimes()
                }) {
                    HStack {
                        Image(systemName: "sunrise")
                            .font(.system(size: 50))
                            .padding()
                            .foregroundColor(.white)

                        Text("Wake Time: \(shortTime(wakeTime))")
                            .foregroundColor(.white)
                    }
                }
                
                if wakeTimePicker {
                    DatePicker("", selection: $wakeTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(WheelDatePickerStyle())
                        .colorInvert()
                }
                Divider().background(Color.white)
            }
        }
        .onAppear {
            UNUserNotificationCenter.current().delegate = UIApplication.shared.delegate as? AppDelegate
            getSavedTimes()
        }
    }
    
    func shortTime(_ date: Date) -> String { // turns long str to shortened version
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    func scheduleAlarm() { // schedules 3 notifications based on selected times
        let preBedTimeAlarm = UNMutableNotificationContent()
        preBedTimeAlarm.title = "Prepare for Sleep!"
        preBedTimeAlarm.body = "Your selected bedtime is approaching in 10 minutes."
        
        let bedTimeAlarm = UNMutableNotificationContent()
        bedTimeAlarm.title = "Time to Sleep!"
        bedTimeAlarm.body = "It is now you scheduled bedtime"
        
        let wakeTimeAlarm = UNMutableNotificationContent()
        wakeTimeAlarm.title = "Time to Wakeup!"
        wakeTimeAlarm.body = "It is now your scheduled wakeup time"
        

        // gets time
        let preBedTime = Calendar.current.date(byAdding: .minute, value: -10, to: bedTime)!
        let preBedComponent = Calendar.current.dateComponents([.hour, .minute], from: preBedTime)
        let bedComponent = Calendar.current.dateComponents([.hour, .minute], from: bedTime)
        let wakeComponent = Calendar.current.dateComponents([.hour, .minute], from: wakeTime)

        // makes trigger
        let preBedTrigger = UNCalendarNotificationTrigger(dateMatching: preBedComponent, repeats: true)
        let bedTrigger = UNCalendarNotificationTrigger(dateMatching: bedComponent, repeats: true)
        let wakeTrigger = UNCalendarNotificationTrigger(dateMatching: wakeComponent, repeats: true)
        
        // notification requests
        let preBedRequest = UNNotificationRequest(identifier: "preBedtimeNotification", content: preBedTimeAlarm, trigger: preBedTrigger)
        let bedRequest = UNNotificationRequest(identifier: "bedtimeNotification", content: bedTimeAlarm, trigger: bedTrigger)
        let wakeRequest = UNNotificationRequest(identifier: "waketimeNotification", content: wakeTimeAlarm, trigger: wakeTrigger)

        
        // schedule notifications
        scheduleNotifications(req: preBedRequest)
        scheduleNotifications(req: bedRequest)
        scheduleNotifications(req: wakeRequest)
    }
    
    func scheduleNotifications(req: UNNotificationRequest) { // does the actual scheduling
        UNUserNotificationCenter.current().add(req) { (error) in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled successfully")
            }
        }
    }
    
    func getSavedTimes() {
        guard let currentUser = Auth.auth().currentUser else {
            print("No current user found")
            return
        }

        let userRef = databaseRef.child("users").child(currentUser.uid)
        userRef.observeSingleEvent(of: .value, with: { snapshot in
            DispatchQueue.main.async {
                if let userDict = snapshot.value as? [String: Any] {
                    if let bed = userDict["bedTime"] as? String,
                       let wake = userDict["wakeTime"] as? String {
                        assignTimes(bed: bed, wake: wake)
                    }
                }
            }
        })
    }
    
    func assignTimes(bed: String, wake: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"

        // Attempt to parse bed time, handle potential errors
        if let bedTime = dateFormatter.date(from: bed) {
            self.bedTime = bedTime
        } else {
            print("Unsuccessful time grab")
        }

        if let wakeTime = dateFormatter.date(from: wake) {
          self.wakeTime = wakeTime
        } else {
          print("Unsuccessful time grab")
        }
    }
    
    func saveSleepTimes() {
        guard let currentUser = Auth.auth().currentUser else {
            print("No current user found")
            return
        }
        let userRef = databaseRef.child("users").child(currentUser.uid)
        let dateFormatter = DateFormatter() // stores the str version of the date
        dateFormatter.dateFormat = "HH:mm"
        
        userRef.child("bedTime").setValue(dateFormatter.string(from: bedTime))
        userRef.child("wakeTime").setValue(dateFormatter.string(from: wakeTime))
    }
    
}



#Preview {
    SleepView()
}
