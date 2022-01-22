//
//  User.swift
//  AudioRecorder
//
//  Created by Igoryok on 22.09.2021.
//

import Foundation


struct User: Equatable, Codable {
    var photoLocation: String
    var name: String
    var surname: String
    var birthDate: Date
    var email: String
    var phoneNumber: String
    var facebookProfileUrl: String
    var cloudSize: Int
    
    
    internal init() {
        self.photoLocation = ""
        self.name = ""
        self.surname = ""
        self.birthDate = Date(timeIntervalSinceReferenceDate: 0)
        self.email = ""
        self.phoneNumber = ""
        self.facebookProfileUrl = ""
        self.cloudSize = CloudDatabase.Plan.free200MB.size
    }
    internal init(photoLocation: String, name: String, surname: String, birthDate: Date, email: String, phoneNumber: String, facebookProfileUrl: String, cloudSize: Int) {
        self.photoLocation = photoLocation
        self.name = name
        self.surname = surname
        self.birthDate = birthDate
        self.email = email
        self.phoneNumber = phoneNumber
        self.facebookProfileUrl = facebookProfileUrl
        self.cloudSize = cloudSize
    }
    
    
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.photoLocation == rhs.photoLocation &&
        lhs.name == rhs.name &&
        lhs.surname == rhs.surname &&
        lhs.birthDate == rhs.birthDate &&
        lhs.email == rhs.email &&
        lhs.phoneNumber == rhs.phoneNumber &&
        lhs.facebookProfileUrl == rhs.facebookProfileUrl &&
        lhs.cloudSize == rhs.cloudSize
    }
    static func load() -> User {
        let userData: Data = UserDefaults.standard.data(forKey: "user") ?? Data()
        let decoder = JSONDecoder()
        
        if let storedData = try? decoder.decode(User.self, from: userData) {
            let user = storedData
            
            return user
        }
        
        return User()
    }
    static func save(_ user: User) {
        let encoder = JSONEncoder()
        
        if let storedData = try? encoder.encode(user) {
            let userData = storedData
            
            UserDefaults.standard.set(userData, forKey: "user")
        }
    }
}
