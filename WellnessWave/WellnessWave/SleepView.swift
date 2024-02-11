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
        }
    }
    
    func shortTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}



#Preview {
    SleepView()
}
