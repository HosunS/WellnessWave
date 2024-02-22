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

struct SleepView: View {
    @State private var bedTime = Date()
    @State private var wakeTime = Date()
    @State private var bedTimePicker = false
    @State private var wakeTimePicker = false
    
    var body: some View {
        VStack {
            Text("Sleep Stability")
            // bedtime
            Image(systemName: "bed.double")
                .font(.system(size: 50))
                .padding()
            
            Button(action: {
                bedTimePicker.toggle()
            }) {
                Text("Select bedtime")
            }
            
            if bedTimePicker {
                DatePicker("", selection: $bedTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(WheelDatePickerStyle())
                    .padding()
            }
            
            Text("Selected time: \(shortTime(bedTime))")
                .padding()
            
            Image(systemName: "clock")
                .font(.system(size: 50))
                .padding()
            
            // wakeup
            Button(action: {
                wakeTimePicker.toggle()
            }) {
                Text("Select wake time")
            }
            
            if wakeTimePicker {
                DatePicker("", selection: $wakeTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(WheelDatePickerStyle())
                    .padding()
            }
            
            Text("Selected time: \(shortTime(wakeTime))")
                .padding()
            
            Button(action: {
                scheduleAlarm()
            }) {
                Text("Schedule Notification")
            }
        }
    }
    
    func shortTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    func scheduleAlarm() {
            let alarm = UNMutableNotificationContent()
            alarm.title = "Time to Sleep!"
            alarm.body = "Your selected bedtime is approaching."

            // Get the components (hour and minute) from the selected bedtime
            let components = Calendar.current.dateComponents([.hour, .minute], from: bedTime)

            // Create a trigger based on the selected bedtime
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

            // Create a notification request
            let request = UNNotificationRequest(identifier: "bedtimeNotification", content: alarm, trigger: trigger)

            // Schedule the notification
            UNUserNotificationCenter.current().add(request) { (error) in
                if let error = error {
                    print("Error scheduling notification: \(error.localizedDescription)")
                } else {
                    print("Notification scheduled successfully")
                }
            }
        }
}



#Preview {
    SleepView()
}
