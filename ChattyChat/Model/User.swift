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
    init?(dictionary: [String: Any]) {
        guard let name = dictionary["name"] as? String else { return nil }
        guard let email = dictionary["email"] as? String else { return nil }
        guard let id = dictionary["user_id"] as? String else { return nil }
        
        self.profileImageUrlString = dictionary["profileImage"] as? String
        self.name = name
        self.email = email
        self.id = id
    }
}
