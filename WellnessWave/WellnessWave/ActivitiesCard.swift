
//
//  ActivitiesCard.swift
//  WellnessWave
//
//  Created by slmrc on 2/9/24.
//

import SwiftUI

struct ActivitiesCard: View {
    var body: some View {
        ZStack{
            
            Color(uiColor: .systemCyan)
                .cornerRadius(20)
            
            VStack{
                
                VStack{
                    Text("Month - Date")
                        .foregroundColor(.white)
        
                }
                
                Divider()
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
                        .foregroundColor(.blue)
                    Spacer()
                    Text("Hours:Minutes")
                        .foregroundColor(.black)
                        .font(.system(size: 16))
                    
                }
                
                HStack{
                    Text("Burned Calories")
                        .foregroundColor(.black)
                        .font(.system(size: 16))
                    Image(systemName: "flame")
                        .font(.system(size: 16))
                        .foregroundColor(.red)
                    Spacer()
                    Text("2000 calories")
                        .foregroundColor(.black)
                        .font(.system(size: 16))
                    
                }
            }.padding()
        }
        
    }
}

struct ActivitiesCard_Previews: PreviewProvider {
    static var previews: some View {
        ActivitiesCard()
    }
}
