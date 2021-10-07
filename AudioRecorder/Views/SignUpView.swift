//
//  SignUpView.swift
//  AudioRecorder
//
//  Created by Igoryok on 07.10.2021.
//

import SwiftUI

struct SignUpView: View {
    @State private var mail: String = ""
    @State private var userName: String = ""
    @State private var userSurname: String = ""
    @State private var birthDate: Date = Date(timeIntervalSinceReferenceDate: 0)
    @State private var password: String = ""
    @State private var isEditing = false
    
    @EnvironmentObject private var appAuth: AppAuth
    
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("Регистрация")
                .font(.title)
                .bold()
                .padding()
            
            TextFieldView(label: "Эл. почта", text: $mail)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .textContentType(.emailAddress)
            
            TextFieldView(label: "Имя", text: $userName)
            
            TextFieldView(label: "Фамилия", text: $userSurname)
            
            HStack {
                Text("Дата рождения:")
                    .font(.title3)
                    .foregroundColor(Color(UIColor.tertiaryLabel))

                Spacer()

                DatePicker("", selection: $birthDate, displayedComponents: .date)
                    .labelsHidden()
            }
            .padding()
            .background(Color(UIColor.systemGray5))
            .cornerRadius(5.0)
            .padding(.vertical, 8)
            
            SecureField(
                    "Пароль",
                    text: $password
                ) {
                    handleLogin(mail: mail, password: password)
                }
                .font(.title3)
                .padding()
                .background(Color(UIColor.systemGray5))
                .cornerRadius(5.0)
                .padding(.vertical, 8)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .textContentType(.newPassword)
            
            SecureField(
                    "Подтвердите пароль",
                    text: $password
                ) {
                    handleLogin(mail: mail, password: password)
                }
                .font(.title3)
                .padding()
                .background(Color(UIColor.systemGray5))
                .cornerRadius(5.0)
                .padding(.vertical, 8)
                .autocapitalization(.none)
                .disableAutocorrection(true)
            
            Button {
                //handleLogin(mail: self.mail, password: self.password)≤
                guard !mail.isEmpty, !password.isEmpty else {
                    return
                }
                print("SignUpButton")
                appAuth.signUp(email: self.mail, password: self.password)
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
            
            Spacer()
        }
        .padding()
    }
    
    
    private func validateMail(mail: String) {
        
    }
    private func handleLogin(mail: String, password: String) {
        
    }
}

struct TextFieldView: View {
    public var label: String
    @Binding public var text: String
    //@Binding public var isEditing = false
    
    
    var body: some View {
        TextField(
            label,
            text: $text
        )
        .font(.title3)
        .padding()
        .background(Color(UIColor.systemGray5))
        .cornerRadius(5.0)
        .padding(.vertical, 8)
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}

