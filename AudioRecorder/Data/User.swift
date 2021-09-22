//
//  User.swift
//  AudioRecorder
//
//  Created by Igoryok on 22.09.2021.
//

import Foundation


class User: ObservableObject, Equatable {
    @Published var photoLocation: String
    @Published var name: String
    @Published var surname: String
    @Published var birthDate: Date
    @Published var email: String
    @Published var phoneNumber: String
    @Published var facebookProfileUrl: String
    
    
    internal init(photoLocation: String, name: String, surname: String, birthDate: Date, email: String, phoneNumber: String, facebookProfileUrl: String) {
        self.photoLocation = photoLocation
        self.name = name
        self.surname = surname
        self.birthDate = birthDate
        self.email = email
        self.phoneNumber = phoneNumber
        self.facebookProfileUrl = facebookProfileUrl
    }
    
    
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.photoLocation == rhs.photoLocation &&
        lhs.name == rhs.name &&
        lhs.surname == rhs.surname &&
        lhs.birthDate == rhs.birthDate &&
        lhs.email == rhs.email &&
        lhs.phoneNumber == rhs.phoneNumber &&
        lhs.facebookProfileUrl == rhs.facebookProfileUrl
    }
}
