//
//  ExerciseView.swift
//  WellnessWave
//
//  Created by Ho sun Song on 2/7/24.
//

import SwiftUI

struct ExerciseView: View {
    @State var selectedDate: Date = Date()
    @State var time: String = ""
    @State var hours: Int = 0
    @State var minutes: Int = 0
    var body: some View {
        ZStack {
            Color(uiColor: .systemGray4)
                .ignoresSafeArea()
            ScrollView {
                VStack {
                    Text("Exercise Planning")
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                        .font(.system(size: 40))
                    Image(systemName: "figure.walk")
                        .foregroundColor(.blue)
                        .font(.system(size: 60))
                }
                .padding(10)
                
                VStack {
                    DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                        .padding(.horizontal)
                        .font(.system(size: 20))
                        .fontWeight(.bold)
                        .padding(10)
                        
                        
                    Text("Workout Duration")
                        .padding(10)
                        .font(.system(size: 20))
                        .foregroundColor(.black)
                    HStack {
                        Picker("", selection: $hours) {
                            ForEach(1..<5, id: \.self) { i in
                                Text("\(i) hours").tag(i)
                                    .foregroundColor(.blue)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        Picker("", selection: $minutes) {
                            ForEach(0..<60, id: \.self) { i in
                                Text("\(i) min").tag(i)
                                    .foregroundColor(.blue)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                    }.padding(.horizontal)

                        
                        Button(role: .none) {} label: {
                            HStack {
                                Spacer()
                                Text("Share workout")
                                    .font(.system(size: 20))
                                Spacer()
                            }
                        }
                        .buttonStyle(.bordered)
                        .foregroundColor(.blue)
                        
        
                        HStack {
                            Text("Best Time: ")
                                .font(.system(size: 20))
                            Spacer()
                            Text("Hours:Minutes")
                                .font(.system(size: 20))
                        }.padding(5)
                    
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                
                
                Section(header: Text("Activity History")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .font(.system(size: 20))) {
                    ForEach(0..<5) { _ in
                        ActivitiesCard()
                            .padding(.horizontal)
                    }
                }
            }
        }
    }
}

struct ExerciseView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseView()
    }
}

