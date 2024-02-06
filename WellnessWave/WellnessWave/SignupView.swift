//
//  SignupView.swift
//  WellnessWave
//
//  Created by Ho sun Song on 1/29/24.
//

import SwiftUI
import FirebaseAuth

struct SignupView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    
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
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress) // Show email keyboard
                        .autocapitalization(.none) // Prevent automatic capitalization
                        .textFieldStyle(.roundedBorder)
                        .padding(5)
                    SecureField("Password", text: $password)
                        .textFieldStyle(.roundedBorder)
                        .padding(5)
                }
                .padding(15)
                Button {
                    signUp(email: email, password: password)
                } label: {
                    Text("Sign Up")
                }
                .padding(.bottom)
            }
            .frame(width: 300.0, height: 600.0)
        }
    }
    
    func signUp(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("Error occurred during sign up: \(error.localizedDescription)")
            } else {
                print("User signed up successfully")
                // update view accordingly
            }
        }
    }
}

struct SignupView_Previews: PreviewProvider {
    static var previews: some View {
        SignupView()
    }
}
