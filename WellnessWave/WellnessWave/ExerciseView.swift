//
//  ExerciseView.swift
//  WellnessWave
//
//  Created by Ho sun Song on 2/7/24.
//

import SwiftUI
import FirebaseAuth
import FirebaseDatabase

struct ExerciseView: View {
    @State var selectedDate: Date = Date()
    @State var hours: Int = 0
    @State var minutes: Int = 0
    private var databaseRef = Database.database().reference()
    @State var recEngine = RecommendationEngine()
    @State private var recommendedTime: String = "Hours:Minutes"
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

                        
                    Button(action: {saveWorkoutDateTime()}){
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
                            Text(recommendedTime)
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
    
    func saveWorkoutDateTime() {
        guard let currentUser = Auth.auth().currentUser else {
            print("No current user found")
            return
        }
        let userRef = databaseRef.child("users").child(currentUser.uid)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        
        userRef.child("selectedDate").setValue(dateFormatter.string(from:selectedDate))
        userRef.child("selectedDuration").setValue(hours*60 + minutes)
        
        recEngine.recommendWorkout { time in
            self.recommendedTime = time // Step 2
        }
    }
    
}



struct ExerciseView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseView()
    }
}

