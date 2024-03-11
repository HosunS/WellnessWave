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
    @State private var workoutHistory: [History] = []
    @State var completedActivities: [History] = []
    @State private var showingCompletionAlert = false
    @State private var selectedHistory: History?
    @State private var workoutTimeRecommended: Bool = false
    
    
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
                        .padding(.top)
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

                        
                    Button(action: {
                        saveWorkoutDateTime()
                        recommendAndSaveWorkout()
                        if self.workoutTimeRecommended == true{
                            addhistory()
                            self.workoutTimeRecommended = false
                        }
                    }){
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
                        ForEach(workoutHistory) { history in
                            Button(action: {
                                self.selectedHistory = history
                                self.showingCompletionAlert = true
                                
                            }) {
                                ActivitiesCard(history: history)
                            }
                            .padding(.horizontal)
                        }

                }
            }
        }.alert(isPresented: $showingCompletionAlert) {
            Alert(
                title: Text("Workout Completion"),
                message: Text("Did you complete the workout on \(selectedHistory?.date ?? "this date")?"),
                primaryButton: .default(Text("Yes"), action: {
                    // Handle workout completion confirmation here
                    if let completedHistory = selectedHistory{
                        self.completeActivity(activity: completedHistory)
                        self.addToCompletedWorkoutsInFirebase(activity: completedHistory)
                        print("Workout completed")
                    }
                }),
                secondaryButton: .cancel(Text("No"))
            )
        }

        
    }
    
    func calculateBurnedCalories(durationMinutes: Int) -> Int {
        // Average calories burned per minute for moderate activity
        let caloriesPerMinute: Double = 8.5
        
        // Calculate total burned calories
        let totalBurnedCalories = Double(durationMinutes) * caloriesPerMinute
        
        return Int(totalBurnedCalories)
    }
    
    func addOrUpdateHistoryItem(newItem: History) {
        if let index = workoutHistory.firstIndex(where: { $0.date == newItem.date }) {
            // An item with the same date exists, update it
            workoutHistory[index] = newItem
        } else {
            // No item with the same date exists, add the new item
            workoutHistory.append(newItem)
        }
    }
    
    // Function to mark an activity as completed
    func completeActivity(activity:History) {
        if let index = workoutHistory.firstIndex(where: { $0.id == activity.id }) {
            var activity = workoutHistory[index]
            activity.completed = true
            
            // Add to completed activities
            completedActivities.append(activity)
            
            // Remove from the current list
            workoutHistory.remove(at: index)
        }
    }
    
    func addToCompletedWorkoutsInFirebase(activity: History) {
        guard let currentUser = Auth.auth().currentUser else { return }
        let userRef = databaseRef.child("users").child(currentUser.uid).child("completedWorkouts")

        // Fetch existing completed workouts
        userRef.observeSingleEvent(of: .value, with: { snapshot in
            var completedWorkouts: [[String: Any]] = []
            
            // Extract existing workouts
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                   let value = snapshot.value as? [String: Any] {
                    completedWorkouts.append(value)
                }
            }
            
            // Add the new completed workout
            let newCompletedActivity = ["date": activity.date,
                                        "hours": activity.hours,
                                        "minutes": activity.minutes,
                                        "burnedCalories": activity.burnedCalories]
            completedWorkouts.append(newCompletedActivity)
            
            // Ensure only the last 7 activities are kept
            let latestWorkouts = Array(completedWorkouts.suffix(7))
            
            // Update Firebase with the latest workouts
            userRef.setValue(latestWorkouts)
        })
    }
    
    func recommendAndSaveWorkout(){
        recEngine.recommendWorkout {time in
            self.recommendedTime = time
            if time != "No suitable time found within preferred hours."{
                self.workoutTimeRecommended = true
                self.saveWorkoutDateTime()
            }else{
                self.workoutTimeRecommended = false
                return
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
        
        
    }
    
    func addhistory(){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyy"
        let burnedCalories = calculateBurnedCalories(durationMinutes: (hours*60 + minutes))
        let newHistory = History(id: workoutHistory.count + 1, date: dateFormatter.string(from: selectedDate), hours: hours, minutes: minutes, burnedCalories: burnedCalories)
        
        addOrUpdateHistoryItem(newItem: newHistory)
    }
    
}



struct ExerciseView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseView()
    }
}

