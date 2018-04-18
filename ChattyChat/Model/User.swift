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

extension User: Hashable {
    var hashValue: Int {
        return id.hashValue
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
