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
    
    var sortedChatIDs = [String]()
    
    public func getCurrentUserInfo(completion: @escaping (Result<User>) -> ()) {
        userManager.getUserInfo(completion: completion)
    }
    
    var currentUserName: String? {
        return userManager.currentUserName
    }
    
    public var chats = [String: Chat]() {
        didSet {
            chatsUpdated(sortedByDateIDs(from: chats))
        }
    }
    
    public func chatForID(_ id: String) -> Chat? {
        return chats[id]
    }
    
    public func getNewChatID(for user: User) -> String {
        return chatService.getIdForNewChat(with: user)
    }
    
    var chatsUpdated: ([String]) -> () = { _ in }
    
    init(with userManager: UserManager, chatService: ChatService) {
        self.userManager = userManager
        self.chatService = chatService
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
    
    public func getSortedChatInfo(completion: @escaping (Bool) -> ()) {
        chatService.getChats { [unowned self] chat in
            chat.keys.forEach({ key in
                self.chats[key] = chat[key]
            })
            self.sortedChatIDs = self.sortedByDateIDs(from: self.chats)
            completion(true)
        }
    }
    
    func getChatID(for user: User) -> String? {
        for id in sortedChatIDs {
            if let chat = chatForID(id), chat.isOnlyMember(userID: user.id) {
                return id
            }
        }
        return nil
    }
    
}
