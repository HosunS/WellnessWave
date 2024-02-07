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
//    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var authViewModel: AuthViewModel
    @State private var navigateToHome: Bool = false

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
                Button(action: {
                    signUp()
                }) {
                    Text("Sign Up")
                        .padding(15)
                        .cornerRadius(10)
                }.padding(.bottom)
            }
            .frame(width: 300.0, height: 600.0)
        }.onReceive(authViewModel.$isAuthenticated) { isAuthenticated in
            if isAuthenticated {
                navigateToHome = true
            }
        }
        .fullScreenCover(isPresented: $navigateToHome) {
            // Navigate to the home screen or another authenticated view
            HomePageView()
        }
    }
    
    //pass actual values into AuthViewModel to create user in db
    func signUp() {
        authViewModel.signUp(email: email, password: password)
    }
}

struct SignupView_Previews: PreviewProvider {
    static var previews: some View {
        SignupView().environmentObject(AuthViewModel())
    }
}
