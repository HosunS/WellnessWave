//
//  HydrationView.swift
//  WellnessWave
//
//  Created by Alejandro Becerra on 2/5/24.
//

import SwiftUI
import HealthKit
import HealthKitUI

struct HydrationView: View {
    @State var waterLevel: CGFloat = 0
    @ObservedObject private var viewModel = HydrationViewModel()
    var body: some View {
        let recommended: Int = Int(viewModel.weight * 0.5)
        
        VStack {
            Text("Recommended amount of water to drink:")
                .font(.title3)
                .fontWeight(.medium)
            Text("\(recommended) oz")
                .font(.title)
                .fontWeight(.semibold)
                .padding(.bottom, 60.0)
            
            //Creating Water Meter
            HStack {
                Spacer()
                ZStack(alignment: .bottomLeading) {
                    
                    RoundedRectangle(cornerRadius: 15)
                        .frame(width:200.0, height: waterLevel*4)
                        .foregroundColor(Color(red: 0.4627, green: 0.8392, blue: 1.0))
                        .animation(Animation.smooth(), value:waterLevel)
                    
                    RoundedRectangle(cornerRadius: 15)
                        .frame(width: 200.0, height: 400.0)
                        .foregroundColor(.blue.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(.black, lineWidth: 3))
                        

                }
                Spacer()
                
                //Oz Buttons and updating waterLevel accordingly
                VStack(spacing: 30) {
                    Button {
                        waterLevel = min(waterLevel + (8.0 * 100.0/CGFloat(recommended)), 100)
                    } label: {
                        Text("8 oz ")
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 40))
                    }
                    Button {
                            waterLevel = min(waterLevel + (16.0 * 100.0/CGFloat(recommended)), 100)
                    } label: {
                        Text("16 oz")
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 40))
                    }
                    Button {
                        waterLevel = min(waterLevel + (32.0 * 100.0/CGFloat(recommended)), 100)
                    } label: {
                        Text("32 oz")
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 40))
                    }
                }
                Spacer()
            }
            Text("\(Int((waterLevel * CGFloat(recommended) * 0.01))) oz consumed")
                .font(.title3)
                .fontWeight(.medium)
                .padding([.top, .leading, .trailing], 20.0)
        }
        .onAppear {
            viewModel.onAppear()
        }
    }
}

#Preview {
    HydrationView()
}

