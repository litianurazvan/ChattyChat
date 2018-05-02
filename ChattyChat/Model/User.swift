//
//  User.swift
//  ChattyChat
//
//  Created by Razvan Litianu on 14/03/2018.
//  Copyright © 2018 Razvan Litianu. All rights reserved.
//

import Foundation

struct User {
    
    let id: String
    let name: String
    let email: String
    let profileImageUrlString: String?
}

extension User: Equatable, Hashable {
    var hashValue: Int {
        return id.hashValue
    }
    
    public static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id &&
            lhs.name == rhs.name &&
            lhs.email == rhs.email &&
            lhs.profileImageUrlString == rhs.profileImageUrlString
    }
}

extension User {
    
    enum Keys: String {
        case id = "user_id"
        case name = "name"
        case email = "email"
        case profileImageUrlString = "profileImage"
    }
    
    init?(id: String, info: [String: Any]) {
        guard let name = info[Keys.name.rawValue] as? String else { return nil }
        guard let email = info[Keys.email.rawValue] as? String else { return nil }
        
        self.profileImageUrlString = info[Keys.profileImageUrlString.rawValue] as? String
        self.name = name
        self.email = email
        self.id = id
    }
    
    init?(dictionary: [String: Any]) {
        guard let id = dictionary[Keys.id.rawValue] as? String else { return nil }
        guard let name = dictionary[Keys.name.rawValue] as? String else { return nil }
        guard let email = dictionary[Keys.email.rawValue] as? String else { return nil }
        
        self.profileImageUrlString = dictionary[Keys.profileImageUrlString.rawValue] as? String
        self.name = name
        self.email = email
        self.id = id
    }
}
