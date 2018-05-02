//
//  UserManager.swift
//  ChattyChat
//
//  Created by Razvan Litianu on 25/04/2018.
//  Copyright © 2018 Razvan Litianu. All rights reserved.
//

import Firebase

enum UserError: Error {
    case userLoggedOut
    case corruptData
}

extension UserError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .userLoggedOut: return "You have been logged out"
        case .corruptData:  return "Could not load info due to corrupt data"
        }
    }
}

enum UploadError: Error {
    case jpegRepresentationFailed
}

class UserManager {
    
    public var currentUserID: String? {
        return Auth.auth().currentUser?.uid
    }
    
    public var currentUserName: String? {
        return Auth.auth().currentUser?.displayName
    }
    
    public var userIsLoggedIn: Bool {
        return Auth.auth().currentUser != nil
    }
    
    public var currentUser: User? {
        guard let firebaseUser = Auth.auth().currentUser else { return nil }
        let name = firebaseUser.displayName ?? "No name"
        let email = firebaseUser.email  ?? "No email"
        let urlString = firebaseUser.photoURL?.absoluteString
        
        return User(id: firebaseUser.uid, name: name, email: email, profileImageUrlString: urlString)
        
    }
    
    var rootReference = Database.database().reference()
    var usersReference: DatabaseReference {
        return rootReference.child("users")
    }
    
    var rootStorageReference = Storage.storage().reference()
    var usersProfileImagesReference: StorageReference {
        return rootStorageReference.child("user-profile-images")
    }
    
    private func getUserInfoWithID(id: String, completion: @escaping (Result<User>) -> ()) {
        usersReference.child(id).observeSingleEvent(of: .value) { snapshot in
            guard let currentUserInfo = snapshot.value as? [String: Any],
                let user = User(id: snapshot.key, info: currentUserInfo) else {
                
                completion(.failure(error: UserError.corruptData))
                return
            }
            
            completion(.success(result: user))
        }
    }
    
    public func getUserInfo(completion: @escaping (Result<User>) -> ()) {
        guard let id = currentUserID else {
            completion(.failure(error: UserError.userLoggedOut))
            return
        }
        getUserInfoWithID(id: id, completion: completion)
    }
    

    public func signIn(withEmail email: String, password: String, completion: @escaping (Result<Firebase.User>) -> ()) {
        Auth.auth().signIn(withEmail: email, password: password) { user, error in
            if let error = error { completion(.failure(error: error)) }
            if let firebaseUser = user {
                completion(.success(result: firebaseUser))
            }
        }
    }
    
    public func createUser(withName name: String, email: String, password: String, urlString: String?, completion: @escaping (Result<Firebase.User>)->()) {
        Auth.auth().createUser(withEmail: email, password: password, completion: { [weak self] user, error in
            if let error = error {
                completion(.failure(error: error))
                return
            }
            
            if let firebaseUser = user,
                let userRef = self?.usersReference.child(firebaseUser.uid) {
                userRef.updateChildValues(["email": email,
                                           "name": name,
                                           "profileImage": urlString ?? ""
                    ])
                
                
                self?.update(user: firebaseUser, name: name, profileImageURLString: urlString, completion: { success in
                    if success {
                        completion(.success(result: firebaseUser))
                    }
                })
                
            }
        })
    }
    
    private func update(user: Firebase.User, name: String, profileImageURLString: String?, completion: @escaping (Bool) -> ()) {
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = name
        changeRequest.photoURL = URL(string: profileImageURLString ?? "")
        changeRequest.commitChanges(completion: { error in
            if error != nil {
                completion(false)
            } else {
                completion(true)
            }
        })
    }
    
    public func uploadProfileImage(_ profileImage: UIImage, completion: @escaping (Result<String?>)->()) {
        
        guard let data = UIImageJPEGRepresentation(profileImage, 0.1) else {
            completion(.failure(error: UploadError.jpegRepresentationFailed))
            return
        }
        let imageStorageRef = usersProfileImagesReference.child("\(NSUUID().uuidString).png")
        
        imageStorageRef.putData(data, metadata: nil) { metadata, error in
            if let error = error { completion(.failure(error: error)) }
            
            if let imageUrlString = metadata?.downloadURL()?.absoluteString {
                completion(.success(result: imageUrlString))
            }
        }
    }
}


