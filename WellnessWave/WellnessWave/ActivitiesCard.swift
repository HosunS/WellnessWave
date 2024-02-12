//
//  ActivitiesCard.swift
//  WellnessWave
//
//  Created by slmrc on 2/9/24.
//

import SwiftUI

struct History{
    let id: Int
    let date: String
    let hours: Int
    let minutes: Int
    let burnedCalories: Int
}

struct ActivitiesCard: View {
    @State var history: History
    var body: some View {
        ZStack{
            
            Color(uiColor: .systemCyan)
                .cornerRadius(20)
            
            VStack{
                
                VStack{
                    HStack{
                        Image(systemName: "calendar")
                            .foregroundColor(.indigo)
                        Text(history.date)
                            .foregroundColor(.black)
                    }
        
                }
                
                Divider()
                    .background(Color.white)
                    .padding(4)
//                HStack{
//                    Text("Start Time")
//                        .font(.system(size: 16))
//                        .foregroundColor(.black)
//                    Image(systemName: "clock")
//                        .font(.system(size: 16))
//                        .foregroundColor(.orange)
//                    Spacer()
//                    Text("Hours:Minutes")
//                        .font(.system(size: 16))
//                        .foregroundColor(.black)
//
//                }
                
                HStack{
                    Text("Workout Duration")
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                    Image(systemName: "fitness.timer")
                        .font(.system(size: 16))
                        .foregroundColor(.yellow)
                    Spacer()
                    Text("\(history.hours)h\(history.minutes)m")
                        .foregroundColor(.black)
                        .font(.system(size: 16))
                    
                }.padding([.bottom], 5)
                
                HStack{
                    Text("Burned Calories")
                        .foregroundColor(.black)
                        .font(.system(size: 16))
                    Image(systemName: "flame")
                        .font(.system(size: 16))
                        .foregroundColor(.red)
                    Spacer()
                    Text("\(history.burnedCalories) calories")
                        .foregroundColor(.black)
                        .font(.system(size: 16))
                    
                }
            }.padding()
        }
        
    }
}

struct ActivitiesCard_Previews: PreviewProvider {
    static var previews: some View {
        ActivitiesCard(history: History(id: 0, date: "02-20", hours: 1, minutes: 30, burnedCalories: 3000))
    }
}
