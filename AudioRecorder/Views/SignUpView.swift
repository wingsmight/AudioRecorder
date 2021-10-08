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
    @State private var repeatedPassword: String = ""
    @State private var isEditing = false
    @State private var errorMessage = ""
    @State private var backgroundColor: Color = Color(UIColor.systemBackground)
    
    @EnvironmentObject private var appAuth: AppAuth
    
    
    var body: some View {
        ZStack {
            backgroundColor
                .edgesIgnoringSafeArea(.all)
            
            ScrollView(showsIndicators: false) {
                Spacer()
                
                TextFieldView(label: "Эл. почта", text: $mail)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                
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
                    text: $repeatedPassword
                ) {
                    
                }
                .font(.title3)
                .padding()
                .background(Color(UIColor.systemGray5))
                .cornerRadius(5.0)
                .padding(.vertical, 8)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.top, 3)
                    .frame(height: 50, alignment: .top)
                    .minimumScaleFactor(0.5)
                
                Button {
                    if self.userName == "" {
                        errorMessage = "Заполните поле 'Имя'!"
                        alertBackground()
                        
                        return
                    } else if userSurname == "" {
                        errorMessage = "Заполните поле 'Фамилия'!"
                        alertBackground()
                        
                        return
                    } else if password != repeatedPassword {
                        errorMessage = "Пароли не совпадают!"
                        alertBackground()
                        return
                    }
                    
                    appAuth.signUp(email: self.mail, password: self.password) {error in
                        errorMessage = AppAuth.localizeAuthError(error)
                    }
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
                .padding(.top, 12)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Регистрация")
            .navigationBarTitleDisplayMode(NavigationBarItem.TitleDisplayMode.inline)
        }
    }
    
    private func alertBackground() {
        withAnimation(.easeInOut(duration: 0.5)) {
            self.backgroundColor = Color.red
            
            withAnimation(.easeInOut(duration: 1)) {
                self.backgroundColor = Color(UIColor.systemBackground)
            }
        }
    }
}

struct TextFieldView: View {
    public var label: String
    @Binding public var text: String
    
    
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

