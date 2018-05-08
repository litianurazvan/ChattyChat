//
//  Chat.swift
//  ChattyChat
//
//  Created by Razvan Litianu on 18/04/2018.
//  Copyright © 2018 Razvan Litianu. All rights reserved.
//

import Firebase

struct Chat {
    let lastMessage: String?
    let timestamp: Double?
    let imageURL: String?
    var members = [String: String]()
}

extension Chat {
    init?(with dictionary: [String: Any]) {
        
        if let membersDict = dictionary["members"] as? [String: String]  {
            members = membersDict
        }
        
        lastMessage = dictionary["lastMessage"] as? String
        timestamp = dictionary["timestamp"] as? Double
        imageURL = dictionary["imageURL"] as? String
    }
}

extension Chat {
    func containsOnly(userID: String) -> Bool {
        // Taking into consideration that members list will include the current user id
        return members.keys.contains(userID) && members.keys.count == 2 ? true : false
    }
}
