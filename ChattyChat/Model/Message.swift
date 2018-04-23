//
//  Message.swift
//  ChattyChat
//
//  Created by Razvan Litianu on 17/04/2018.
//  Copyright © 2018 Razvan Litianu. All rights reserved.
//

import Foundation

struct Message {
    let content: String
    let recipientID: String
    let senderID: String
    let timeStamp: Double
}

extension Message {
    init?(from dictionary: [String: Any]) {
        guard let content = dictionary["content"] as? String else { return nil }
        guard let recipientID = dictionary["recipient_id"] as? String else { return nil }
        guard let senderID = dictionary["sender_id"] as? String else { return nil }
        guard let timeStamp = dictionary["timestamp"] as? Double else { return nil }
        
        self.content = content
        self.recipientID = recipientID
        self.senderID = senderID
        self.timeStamp = timeStamp
    }
}
