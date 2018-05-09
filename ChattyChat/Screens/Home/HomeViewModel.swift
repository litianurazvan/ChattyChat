//
//  HomeViewModel.swift
//  ChattyChat
//
//  Created by Razvan Litianu on 25/04/2018.
//  Copyright © 2018 Razvan Litianu. All rights reserved.
//

import Foundation

class HomeViewModel {
    
    private let userManager: UserManager
    private let chatService: ChatService
    
    var sortedChatIDs = [String]() {
        didSet {
            chatDidChange()
        }
    }
    
    public var chatDidChange: ()->() = {}
    
    
    private var chats = [String: Chat]() {
        didSet {
            sortedChatIDs = sortedByDateIDs(from: chats)
        }
    }
    
    public func getCurrentUserInfo(completion: @escaping (Result<User>) -> ()) {
        userManager.getUserInfo(completion: completion)
    }
    
    var currentUserName: String? {
        return userManager.currentUserName
    }
    
    
    private func chatForID(_ id: String) -> Chat? {
        return chats[id]
    }
    
    public func getNewChatID(for user: User) -> String {
        return chatService.createNewChat(with: user)
    }
    
    init(with userManager: UserManager, chatService: ChatService) {
        self.userManager = userManager
        self.chatService = chatService
        chatService.observer = self
    }
    
    private func sortedByDateIDs(from chats: [String: Chat]) -> [String] {
        return chats.keys.sorted {
            guard let lhsChat = chats[$0], let rhsChat = chats[$1] else {
                return false
            }
            
            guard let lhsTimestamp = lhsChat.timestamp, let rhsTimestamp = rhsChat.timestamp else {
                return false
            }
            
            return lhsTimestamp > rhsTimestamp
        }
    }
    
    func getChatID(for user: User) -> String? {
        for id in sortedChatIDs {
            if let chat = chatForID(id), chat.containsOnly(userID: user.id) {
                return id
            }
        }
        return nil
    }
    
    func chatCellViewModel(for indexPath: IndexPath) -> ChatCellViewModel? {
        let chatID = sortedChatIDs[indexPath.row]
        guard let chat = chatForID(chatID), let currentUserName = currentUserName else { return nil }
        return ChatCellViewModel(chat: chat, currentUserName: currentUserName)
    }
    
}

extension HomeViewModel: ChatDetailsObserver {
    func chatService(_ chatService: ChatService, didDownload chatInfo: [String : Chat]) {
        chats.merge(chatInfo) { (_, new) in new }
    }
}
