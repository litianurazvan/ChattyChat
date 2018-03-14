//
//  User.swift
//  ChattyChat
//
//  Created by Razvan Litianu on 14/03/2018.
//  Copyright © 2018 Razvan Litianu. All rights reserved.
//

import Foundation

struct User {
    let name: String
    let email: String
}

extension User {
    init?(dictionary: [String: Any]) {
        guard let name = dictionary["name"] as? String else { return nil }
        guard let email = dictionary["email"] as? String else { return nil }
        
        self.name = name
        self.email = email
    }
}
