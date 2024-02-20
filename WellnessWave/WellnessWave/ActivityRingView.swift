//
//  ActivityRingView.swift
//  WellnessWave
//use this view to create the rings on dashboard
//  Created by Ho sun Song on 2/20/24.
//
import SwiftUI
import HealthKit
import HealthKitUI

struct ActivityRingView: View {
    var progress: Double
    var goal: Double
    var color: Color
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 10)
                .opacity(0.3)
                .foregroundColor(color)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(self.progress / self.goal, 1)))
                .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .foregroundColor(color)
                .rotationEffect(Angle(degrees: 270))
                .animation(.linear, value: progress)
        }
    }
}
