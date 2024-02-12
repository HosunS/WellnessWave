//
//  ExerciseView.swift
//  WellnessWave
//
//  Created by Ho sun Song on 2/7/24.
//

import SwiftUI

struct ExerciseView: View {
    @State var selectedDate: Date = Date()
    @State var hours: Int = 0
    @State var minutes: Int = 0
    var body: some View {
        ZStack {
            Color(uiColor: .black)
                .ignoresSafeArea()
            ScrollView {
                VStack {
                    Text("Exercise Planning")
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                        .font(.system(size: 40))
                    Image(systemName: "dumbbell.fill")
                        .foregroundColor(.red)
                        .font(.system(size: 70))
                        .padding([.top], 2)
                        
                }
                .padding(10)
                
                VStack {
                    DatePicker("Select Date", selection: $selectedDate, in: Date()..., displayedComponents: .date)
                        .padding(10)
                        .font(.system(size: 20))
                        .fontWeight(.bold)
                        .padding(10)
                        .background(.cyan)
                        .cornerRadius(20)
                        
                        
                    Text("Workout Duration")

                        .font(.system(size: 20))
                        .foregroundColor(.gray)
                        .fontWeight(.bold)
                    HStack {
                        Picker("", selection: $hours) {
                            ForEach(0..<5, id: \.self) { i in
                                Text("\(i) hours").tag(i)
                                    .foregroundColor(.blue)
                                    .fontWeight(.bold)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        Picker("", selection: $minutes) {
                            ForEach(0..<60, id: \.self) { i in
                                Text("\(i) min").tag(i)
                                    .foregroundColor(.blue)
                                    .fontWeight(.bold)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                    }.padding(.horizontal)

                        
                        Button(role: .none) {} label: {
                            HStack {
                                Spacer()
                                Text("Share workout")
                                    .font(.system(size: 20))
                                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                                Spacer()
                            }
                        }
                        
                        .buttonStyle(.bordered)
                        .foregroundColor(.blue)
                        .background(Color.white)
                        
                        
        
                        HStack {
                            Text("Best Time")
                                .font(.system(size: 20))
                                .fontWeight(.bold)
                                .foregroundColor(.gray)
                            Spacer()
                            Image(systemName: "cursorarrow.click.badge.clock")
                                .font(.system(size: 20))
                                .foregroundColor(.red)
                            Text("Hours:Minutes")
                                .font(.system(size: 20))
                                .foregroundColor(.red)
                                .fontWeight(.bold)
                                .padding(6)
                                
                                .background {
                                    Color.gray.opacity(0.3)
                                        .ignoresSafeArea()
                                }.cornerRadius(10)
                                
                        }.padding(5)
                    
                }
                .padding()
                .background(Color.clear)
                .cornerRadius(10)
                
                Section(header: Text("Activity History")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                    .font(.system(size: 20))) {
                    ForEach(0..<5) { _ in
                        ActivitiesCard(history: History(id: 0, date: "02-20", hours: 1, minutes: 30, burnedCalories: 3000))
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

