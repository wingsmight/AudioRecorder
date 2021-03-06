//
//  SignUpView.swift
//  AudioRecorder
//
//  Created by Igoryok on 07.10.2021.
//

import SwiftUI
import FirebaseFirestore

struct SignUpView: View {
    @State private var email: String = ""
    @State private var userName: String = ""
    @State private var userSurname: String = ""
    @State private var birthDate: Date = Date(timeIntervalSinceReferenceDate: 0)
    @State private var password: String = ""
    @State private var repeatedPassword: String = ""
    @State private var isEditing = false
    @State private var errorMessage = ""
    @State private var backgroundColor: Color = Color(UIColor.systemBackground)
    
    @AppStorage("user") var userData: Data = Data()
    
    @EnvironmentObject private var appAuth: AppAuth
    
    
    var body: some View {
        ZStack {
            backgroundColor
                .edgesIgnoringSafeArea(.all)
            
            ScrollView(showsIndicators: false) {
                Spacer()
                
                TextFieldView(label: "Эл. почта", text: $email)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                
                TextFieldView(label: "Имя", text: $userName)
                
                TextFieldView(label: "Фамилия", text: $userSurname)
                
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
                .textContentType(.newPassword)
                
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
                    
                    appAuth.signUp(
                        email: self.email,
                        password: self.password,
                        handleError: {error in
                            errorMessage = AppAuth.localizeAuthError(error)
                        
                            alertBackground()
                        },
                        handleSuccess: {
                            let user = User(photoLocation: "", name: self.userName, surname: self.userSurname, birthDate: self.birthDate, email: self.email, phoneNumber: "", facebookProfileUrl: "", cloudSize: CloudDatabase.Plan.free200MB.size)
                            
                            CloudDatabase.addData(user: user)
                            User.save(user)
                        })
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

