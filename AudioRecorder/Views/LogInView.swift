//
//  LogInView.swift
//  AudioRecorder
//
//  Created by Igoryok on 07.10.2021.
//

import SwiftUI

struct LogInView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isEditing = false
    
    @EnvironmentObject private var appAuth: AppAuth
    
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                
                Text("Добро пожаловать!")
                    .font(.title)
                    .bold()
                    .padding()
                
                TextField(
                        "Эл. почта",
                         text: $email
                    ) { isEditing in
                        self.isEditing = isEditing
                    } onCommit: {
                        validateUsername(name: email)
                    }
                    .font(.title3)
                    .padding()
                    .background(Color(UIColor.systemGray5))
                    .cornerRadius(5.0)
                    .padding(.vertical, 8)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .textContentType(.emailAddress)
                
                SecureField(
                        "Пароль",
                        text: $password
                    ) {
                        handleLogin(username: email, password: password)
                    }
                    .font(.title3)
                    .padding()
                    .background(Color(UIColor.systemGray5))
                    .cornerRadius(5.0)
                    .padding(.vertical, 8)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .textContentType(.password)
                
                Button {
                    //handleLogin(username: self.username, password: self.password)
                    
                    guard !email.isEmpty, !password.isEmpty else {
                        return
                    }
                    print("LogInButton")
                    appAuth.logIn(email: self.email, password: self.password)
                } label: {
                    Text("Войти")
                        .bold()
                        .font(.title3)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 210, height: 55)
                        .background(Color.green)
                        .cornerRadius(15.0)
                }
                .padding(.top, 30)
                
                Text("Нет аккаунта?")
                    .padding(.top, 18)
                NavigationLink("Создать", destination: SignUpView())
                    .padding(.top, 1)
                
                Spacer()
            }
            .padding()
        }
    }
    
    
    private func validateUsername(name: String) {
        
    }
    private func handleLogin(username: String, password: String) {
        
    }
}

struct LogInView_Previews: PreviewProvider {
    static var previews: some View {
        LogInView()
            
    }
}
