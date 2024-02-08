//
//  WelcomeView.swift
//  WellnessWave
//
//  Created by Ho sun Song on 1/29/24.
//

//import frameworks for ui as well as accessing health and fitness data
import SwiftUI
import UIKit

struct WelcomeView: View {

    
    var body: some View {
        NavigationStack{
            VStack(alignment: .center, spacing: 20){
                Text("WellnessWave")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 15.0)
                Text("Making Time for Your Health")
                    .font(.title)
                    .fontWeight(.semibold)
                    .padding(.bottom, 100.0)
                
                NavigationLink(destination: LogInView()){
                    LoginButtonContent()
                        .environmentObject(AuthViewModel())
                }
                
                NavigationLink(destination:SignupView()){
                    SignupButtonContent()
                        .environmentObject(AuthViewModel())
                }
            }
        }
    }
}
    struct WelcomeView_Previews: PreviewProvider {
        static var previews: some View{
            WelcomeView().environmentObject(AuthViewModel())
        }
    }
    
    struct SignupButtonContent: View{
        var body: some View{
            return Text("SIGN UP")
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: 110, height: 40)
                .background(Color.blue)
                .cornerRadius(5.0)
                .padding(.horizontal,50)
        }
    }
    
    struct LoginButtonContent: View{
        var body: some View{
            return Text("LOG IN")
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: 110, height: 40)
                .background(Color.green)
                .cornerRadius(5.0)
        }
    }
    

