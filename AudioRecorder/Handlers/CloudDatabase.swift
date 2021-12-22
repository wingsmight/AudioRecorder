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


//func updateData(todoToUpdate: Todo) {
//
//    // Get a reference to the database
//    let db = Firestore.firestore()
//
//    // Set the data to update
//    db.collection("todos").document(todoToUpdate.id).setData(["name":"Updated: \(todoToUpdate.name)"], merge: true) { error in
//
//        // Check for errors
//        if error == nil {
//            // Get the new data
//            self.getData()
//        }
//    }
//}
//
//func deleteData(todoToDelete: Todo) {
//
//    // Get a reference to the database
//    let db = Firestore.firestore()
//
//    // Specify the document to delete
//    db.collection("todos").document(todoToDelete.id).delete { error in
//
//        // Check for errors
//        if error == nil {
//            // No errors
//
//            // Update the UI from the main thread
//            DispatchQueue.main.async {
//
//                // Remove the todo that was just deleted
//                self.list.removeAll { todo in
//
//                    // Check for the todo to remove
//                    return todo.id == todoToDelete.id
//                }
//            }
//        }
//    }
//}

func uploadRecord(currentUserId: String, audio: URL, completion: @escaping (Result<URL, Error>) -> Void) {
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
        }
    }
}

func downloadRecord(currentUserId: String, fileName: String, completion: @escaping (Result<URL, Error>) -> Void) {
    let ref = Storage.storage().reference().child("audioRecords").child(currentUserId).child(fileName)
    
    ref.downloadURL { (url, error) in
        guard let url = url else {
            completion(.failure(error!))
            return
        }
        completion(.success(url))
    }
}

func addData(user: User) {
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

func getData(email: String) {
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

func getStoredSize(currentUserId: String, onSizeUpdated: @escaping (Int) -> Void) {
    var storedBytes: Int = 0
    let ref = Storage.storage().reference().child("audioRecords").child(currentUserId)
    
    ref.listAll { storageListResult, error in
        for item in storageListResult.items {
            item.getMetadata { itemMetadata, itemError in
                storedBytes += Int(truncatingIfNeeded: itemMetadata?.size ?? 0)
                onSizeUpdated(storedBytes)
            }
        }
    }
}
