//
//  LogInView.swift
//  AudioRecorder
//
//  Created by Igoryok on 07.10.2021.
//

import SwiftUI
import Firebase

struct LogInView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isEditing = false
    @State private var errorMessage = ""
    @State private var backgroundColor: Color = Color(UIColor.systemBackground)
    
    @AppStorage("user") var userData: Data = Data()
    
    @EnvironmentObject private var appAuth: AppAuth
    
    
    var body: some View {
        NavigationView {
            ZStack {
                backgroundColor
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Spacer()
                        .padding()
                    
                    Text("Добро пожаловать!")
                        .font(.title)
                        .bold()
                        .padding()
                    
                    TextField("Эл. почта", text: $email, onCommit: {
                        
                            })
                        .font(.title3)
                        .padding()
                        .background(Color(UIColor.systemGray5))
                        .cornerRadius(5.0)
                        .padding(.vertical, 8)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                    
                    SecureField(
                            "Пароль",
                            text: $password
                        ) {
                            
                        }
                        .font(.title3)
                        .padding()
                        .background(Color(UIColor.systemGray5))
                        .cornerRadius(5.0)
                        .padding(.top, 8)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .textContentType(.password)
                        .keyboardType(UIKit.UIKeyboardType.default)
                    
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(.top, 3)
                        .frame(height: 50, alignment: .top)
                        .minimumScaleFactor(0.5)
                    
                    Button {
                        appAuth.logIn(
                            email: self.email,
                            password: self.password,
                            handleError: {error in
                                errorMessage = AppAuth.localizeAuthError(error)
                            
                                alertBackground()
                            },
                            handleSuccess: {
                                CloudDatabase.getData(email: self.email)
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
                    
                    Text("Нет аккаунта?")
                        .padding(.top, 18)
                    NavigationLink("Создать", destination: SignUpView())
                        .padding(.top, 1)
                    
                    Spacer()
                        .padding(.bottom, 50)
                }
                .padding()
                .onTapGesture {
                    UIApplication.shared.endEditing()
                }
            }
            .navigationBarHidden(true)
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

struct LogInView_Previews: PreviewProvider {
    static var previews: some View {
        LogInView()
            
    }
}
