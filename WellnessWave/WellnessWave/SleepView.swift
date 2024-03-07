//
//  SleepView.swift
//  WellnessWave
//
//  Created by Ho sun Song on 2/7/24. Edited by Tom Wang
//

import SwiftUI
import Foundation
import UserNotifications
import UIKit
import FirebaseAuth
import FirebaseDatabase
import HealthKit

struct SleepView: View {
    @State private var bedTime = Date()
    @State private var wakeTime = Date()
    @State private var bedTimePicker = false
    @State private var wakeTimePicker = false
    @State private var sleepCheck = true // checks if user slept the right amount (true for user still needs to do/ false if they already inputted)
    @State private var lastSleepCheck = Date() // last time user inputted their sleep time
    
    @State private var pastBedTimes: [String] = []
    @State private var pastWakeTimes: [String] = []
    @State private var pastSleepQuality: [Int] = []
    private var databaseRef = Database.database().reference()
    
    var body: some View {
        ZStack {
            Spacer()
            Color.black.edgesIgnoringSafeArea(.top)
            VStack (alignment: .leading){
                Text("Score: \(Int(lifeStyleScore()))/100")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                
                Divider().background(Color.white)
                
                if sleepCheck {
                    HStack {
                        Button("Slept Within 30 min") {
                            addSleepQuality(score: 100)
                        }
                        .padding()
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 1)
                        )

                        Button("Slept Within 1 Hour") {
                            addSleepQuality(score: 80)
                        }
                        .padding()
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 1)
                        )

                        Button("Slept Within 2 Hours") {
                            addSleepQuality(score: 60)
                        }
                        .padding()
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 1)
                        )

                        Button("Slept After 2 Hours") {
                            addSleepQuality(score: 0)
                        }
                        .padding()
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                    }
                }
                
                Text("Current Alarms: ")
                    .foregroundColor(.white)
                    .font(.largeTitle)
                    

                // bedtime
                Button(action: {
                    bedTimePicker.toggle()
                    scheduleAlarm()
                    saveSleepTimes(type: "bed", closed: bedTimePicker)
                    
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
                    saveSleepTimes(type: "wake", closed: wakeTimePicker)
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
                .foregroundColor(.white)
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
                    if let pastBed = userDict["pastBedTimes"] as? [String],
                       let pastWake = userDict["pastWakeTimes"] as? [String],
                       let pastQuality = userDict["pastSleepQuality"] as? [Int] {
                        assignTimes(pastBed: pastBed, pastWake: pastWake, pastQuality : pastQuality)
                    }
                }
            }
        })
    }
    
    func assignTimes(pastBed: [String], pastWake: [String], pastQuality: [Int]) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"

        if let lastWake = pastWake.last {
            if let wakeTime = dateFormatter.date(from: lastWake) {
                self.wakeTime = wakeTime
            }
        }
        
        if let lastBed = pastBed.last {
            if let bedTime = dateFormatter.date(from: lastBed) {
                self.bedTime = bedTime
            }
        }
        
        self.pastBedTimes = pastBed
        self.pastWakeTimes = pastWake
        self.pastSleepQuality = pastQuality
    }
    
    func saveSleepTimes(type: String, closed: Bool) {
        guard let currentUser = Auth.auth().currentUser else {
            print("No current user found")
            return
        }
        let userRef = databaseRef.child("users").child(currentUser.uid)
        let dateFormatter = DateFormatter() // stores the str version of the date
        dateFormatter.dateFormat = "HH:mm"
        
        if type == "bed" && !closed {
            self.pastBedTimes.append(dateFormatter.string(from: bedTime))
            if self.pastBedTimes.count > 7 {
                self.pastBedTimes.removeFirst()
            }
        } else if type == "wake" && !closed {
            self.pastWakeTimes.append(dateFormatter.string(from: wakeTime))
            if self.pastWakeTimes.count > 7 {
                self.pastWakeTimes.removeFirst()
            }
        }
        
        userRef.child("pastBedTimes").setValue(pastBedTimes)
        userRef.child("pastWakeTimes").setValue(pastWakeTimes)
        
    }
    
    func addSleepQuality(score: Int) {
        self.sleepCheck = false
        self.pastSleepQuality.append(score)
        if self.pastSleepQuality.count > 7 {
            self.pastSleepQuality.removeFirst()
        }
        guard let currentUser = Auth.auth().currentUser else {
            print("No current user found")
            return
        }
        let userRef = databaseRef.child("users").child(currentUser.uid)
        
        userRef.child("pastSleepQuality").setValue(pastSleepQuality)
    }
    
    func lifeStyleScore() -> Double {
        if self.pastSleepQuality.count < 1 {
            return 0
        }
        let sum = Double(self.pastSleepQuality.reduce(0, +))
        let mean = sum / Double(self.pastSleepQuality.count)
        return mean
    }
    
    
    
}



#Preview {
    SleepView()
}
