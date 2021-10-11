//
//  AppAuth.swift
//  AudioRecorder
//
//  Created by Igoryok on 07.10.2021.
//

import Foundation
import Firebase

class AppAuth: ObservableObject {
    let auth = Auth.auth()
    
    @Published var signedIn = false
    
    var isSignedIn: Bool {
        auth.currentUser != nil
    }
    var currentUser: FirebaseAuth.User? {
        auth.currentUser
    }
    
    
    func logIn(email: String, password: String, handleError:  @escaping (AuthErrorCode) -> Void, handleSuccess:  @escaping () -> Void) {
        auth.signIn(withEmail: email, password: password) { [weak self] result, error in
                guard result != nil, error == nil else {
                    if let errorCode = AuthErrorCode(rawValue: error!._code) {
                        handleError(errorCode)
                    }
                    
                    return
                }
            
            DispatchQueue.main.async {
                // Success
                self?.signedIn = true
                handleSuccess()
            }
        }
    }
    func signUp(email: String, password: String, handleError:  @escaping (AuthErrorCode) -> Void, handleSuccess:  @escaping () -> Void) {
        auth.createUser(withEmail: email, password: password) { [weak self] result, error in
            guard result != nil, error == nil else {
                if let errorCode = AuthErrorCode(rawValue: error!._code) {
                    handleError(errorCode)
                }
                
                return
            }
            
            DispatchQueue.main.async {
                // Success
                self?.signedIn = true
                handleSuccess()
            }
        }
    }
    func signOut() {
        if self.signedIn {
            try? auth.signOut()
            
            self.signedIn = false
        }
    }
    
    public static func localizeAuthError(_ errorCode: AuthErrorCode) -> String {
        var errorMessage: String {
            switch errorCode {
            case .emailAlreadyInUse:
                return "Данная эл. почта уже занята под другой аккаунт!"
            case .userNotFound:
                return "Данный пользователь отстуствует. Проверьте поля и повторите!"
            case .userDisabled:
                return "Данный пользователь отключен. Свяжитесь с поддержкой!"
            case .invalidEmail, .invalidSender, .invalidRecipientEmail:
                return "Пожалуйста, введите корректную эл. почту!"
            case .networkError:
                return "Возникла ошибка в сети. Пожалуйста, попробуйте снова!"
            case .weakPassword:
                return "Слишком слабый пароль. Пароль должен содержать как минимум 6 символов!"
            case .wrongPassword:
                return "Некорректный пароль. Пожалуйста, повторите снова или нажмите на 'Сбросить пароль'"
            default:
                return "Произошла неизвестная ошибка. Свяжитесь с поддержкой. Код ошибки: \(errorCode.rawValue)"
            }
        }
        
        return errorMessage
    }
}
