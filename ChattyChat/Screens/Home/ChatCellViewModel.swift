//
//  ChatCellViewModel.swift
//  ChattyChat
//
//  Created by Razvan Litianu on 08/05/2018.
//  Copyright © 2018 Razvan Litianu. All rights reserved.
//

import Foundation

struct ChatCellViewModel {
    
    private let chat: Chat
    private let currentUserName: String
    
    init(chat: Chat, currentUserName: String) {
        self.chat = chat
        self.currentUserName = currentUserName
    }
}

extension ChatCellViewModel {
    private var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("h:mm a")
        return dateFormatter
    }
    
    public var chatTitle: String {
        return chat.members.values.filter{ $0 != currentUserName }.reduce("", {$0 + $1})
    }
    
    public var imageURL: String? {
        return chat.imageURL
    }
    
    public var lastMessage: String {
        return chat.lastMessage ?? "Start a new conversation"
    }
    
    public var timeSent: String {
        return dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(chat.timestamp ?? 0)))
    }
    
}

