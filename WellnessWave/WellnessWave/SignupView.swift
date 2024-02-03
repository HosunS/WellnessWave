//
//  SignupView.swift
//  WellnessWave
//
//  Created by Ho sun Song on 1/29/24.
//

import SwiftUI

struct SignupView: View {
    @State var username: String = ""
    @State var password: String = ""
    var body: some View {
        ZStack {
            Color(.mint)
                .ignoresSafeArea()
            RoundedRectangle(cornerRadius: 25)
                .foregroundColor(.white)
                .frame(width: 300.0, height: 600.0)
                .aspectRatio(contentMode: .fit)
                .padding(.horizontal, 50.0)
            VStack {
                Text("Wellness Wave").font(.title).fontWeight(.bold).padding(15)
                VStack {
                    TextField("Username", text: $username)
                    TextField("Password", text: $password)
                }
                .textFieldStyle(.roundedBorder)
                .padding(15)
                Button {
                    SignUp(user: username, pass: password)
                } label: {
                    Text("Sign Up")
                }
                .padding(.bottom)
            }
            .frame(width: 300.0, height: 600.0)
            
        }
        
    }
    func SignUp(user:String, pass:String) {
        print("Your username is \(user)")
        print("Your password is \(pass)")
    }
}

#Preview {
    SignupView()
}
