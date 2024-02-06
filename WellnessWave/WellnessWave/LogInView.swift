//
//  LogInView.swift
//  WellnessWave
//
//  Created by Ho sun Song on 1/29/24.
//

import SwiftUI
import FirebaseAuth

struct LogInView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = "Login Error"

    var body: some View {
        ZStack {
            Color.blue
                .ignoresSafeArea()
            RoundedRectangle(cornerRadius: 25)
                .foregroundColor(.white)
                .frame(width: 300, height: 600)
                .aspectRatio(contentMode: .fit)
                .padding(.horizontal, 50)
            VStack {
                Spacer()
                Text("Wellness Wave")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(15)
                
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .textFieldStyle(.roundedBorder)
                    .padding(15)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)
                    .padding(15)
                
                Button(action: {
                    logIn(email: email, password: password)
                }) {
                    Text("Login")
                        .padding(15)
                        .cornerRadius(10)
                }
                .padding(.bottom)
                
                Spacer()
            }
            .frame(width: 300, height: 600)
            .alert(isPresented: $showingAlert) {
                Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    func logIn(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error as NSError? {
                self.showingAlert = true
                self.alertMessage = error.localizedDescription
                self.alertTitle = "Login Error"
            } else {
                self.showingAlert = true
                self.alertMessage = "You're now logged in!"
                self.alertTitle = "Success"
                // Handle successful login, for example, by updating the view or transitioning to another part of your app
            }
        }
    }
}

struct LogInView_Previews: PreviewProvider {
    static var previews: some View {
        LogInView()
    }
}
