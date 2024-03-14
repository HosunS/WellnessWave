//
//  TransitionView.swift
//  WellnessWave
//
//  Created by Ho sun Song on 3/14/24.
//

import SwiftUI

struct TransitionView: View {
    var body: some View {
        ZStack {
            Color.black
            VStack {
                Text("Loading...")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
            }
        }
    }
}

#Preview {
    TransitionView()
}
