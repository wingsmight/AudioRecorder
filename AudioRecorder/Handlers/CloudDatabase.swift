//
//  CloudDatabase.swift
//  AudioRecorder
//
//  Created by Igoryok on 09.10.2021.
//

import Foundation
import Firebase
import FirebaseStorage
import FirebaseFirestore
import SwiftUI


class CloudDatabase {
    @AppStorage("availableStorageSize") private static var availableStorageSize: Int = Plan.free200MB.size
    @AppStorage("usedStorageSize") private static var usedStorageSize: Int = 0
    @AppStorage("storageFillPercent") private static var storageFillPercent: Double = 0.0

    
    public static func uploadRecord(currentUserId: String, audio: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        if isStorageFull {
            completion(.failure(NSError(domain: "Cloud storage is full", code: -1, userInfo: nil)))
            
            return
        }
        
        let ref = Storage.storage().reference().child("audioRecords").child(currentUserId).child(audio.lastPathComponent)
        
        let metadata = StorageMetadata()
        metadata.contentType = "audio/m4a"
        
        guard let audioData = try? Data(contentsOf: audio) else { return }
        
        ref.putData(audioData , metadata: metadata) { (metadata, error) in
            guard let _ = metadata else {
                completion(.failure(error!))
                return
            }
            ref.downloadURL { (url, error) in
                guard let url = url else {
                    completion(.failure(error!))
                    return
                }
                completion(.success(url))
                updateUsedStorageSize(currentUserId: currentUserId)
            }
        }
    }
    public static func downloadRecord(currentUserId: String, fileName: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let ref = Storage.storage().reference().child("audioRecords").child(currentUserId).child(fileName)
        
        ref.downloadURL { (url, error) in
            guard let url = url else {
                completion(.failure(error!))
                return
            }
            completion(.success(url))
        }
    }
    public static func addData(user: User) {
        // Get a reference to the database
        let database = Firestore.firestore()
        
        database.collection("users").addDocument(data:
                                                    ["email": user.email,
                                                     "name": user.name,
                                                     "surname": user.surname,
                                                     "photoURL": user.photoLocation, // TODO
                                                     "birthDate": user.birthDate,
                                                     "facebookProfileUrl": user.facebookProfileUrl,
                                                     "phoneNumber": user.phoneNumber]) { error in
            if error != nil {
                print(#function, error)
            } else {
                
            }
        }
    }
    public static func getData(email: String) {
        // Get a reference to the database
        let database = Firestore.firestore()
        
        // Read the documents at a specific path
        database.collection("users").whereField("email", isEqualTo: email).getDocuments { snapshot, error in
            if error == nil {
                if let snapshot = snapshot {
                    DispatchQueue.main.async {
                        let users: [User] = snapshot.documents.map { data in
                            print("user id = \(data.documentID)")
                            
                            return User(photoLocation: data["photoURL"] as! String, name: data["name"] as! String, surname: data["surname"] as! String, birthDate: (data["birthDate"] as! Timestamp).dateValue(), email: data["email"] as! String, phoneNumber: data["phoneNumber"] as! String, facebookProfileUrl: data["facebookProfileUrl"] as! String)
                        }
                        
                        User.save(users[0])
                    }
                }
            }
            else {
                // Handle the error
            }
        }
    }
    public static func updateUsedStorageSize(currentUserId: String) {
        var storedBytes: Int = 0
        let ref = Storage.storage().reference().child("audioRecords").child(currentUserId)
        
        ref.listAll { storageListResult, error in
            for item in storageListResult.items {
                item.getMetadata { itemMetadata, itemError in
                    storedBytes += Int(truncatingIfNeeded: itemMetadata?.size ?? 0)
                    usedStorageSize = storedBytes
                    storageFillPercent = Double(usedStorageSize) / Double(availableStorageSize)
                }
            }
        }
    }
    public static func changeStoragePlan(user: Firebase.User, newPlan: Plan, onSuccess: @escaping () -> Void) {
        availableStorageSize = newPlan.size
        
        let email = user.email
        let database = Firestore.firestore()
        
        // Read the documents at a specific path
        database.collection("users").whereField("email", isEqualTo: email).getDocuments { snapshot, error in
            if error == nil && snapshot != nil {
                if let snapshot = snapshot {
                    DispatchQueue.main.async {
                        let document = snapshot.documents.first
                        if let document = document {
                            document.reference.updateData([
                                "storageSize": newPlan.size
                            ])
                            
                            storageFillPercent = Double(usedStorageSize) / Double(availableStorageSize)
                            onSuccess()
                        } else {
                            //onError()
                        }
                    }
                } else {
                    //onError()
                }
            }
            else {
                // Handle the error
                //onError()
            }
        }
    }
    
    
    public static var isStorageFull: Bool {
        usedStorageSize >= availableStorageSize
    }
    
    
    public enum Plan {
        case free200MB
        case paid2GB
        

        public var size: Int {
            switch self {
            case .free200MB:
                return 200 * 1024 * 1024
            case .paid2GB:
                return 2 * 1024 * 1024 * 1024
            }
        }
    }
}
