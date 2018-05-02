//
//  ChatService.swift
//  ChattyChat
//
//  Created by Razvan Litianu on 25/04/2018.
//  Copyright © 2018 Razvan Litianu. All rights reserved.
//

import Firebase

struct ChatService {
    
    private var currentUser: User
    
    init(user: User) {
        self.currentUser = user
    }
    
    private var rootReference = Database.database().reference()
    
    private var chatsReference: DatabaseReference {
        return rootReference.child("chats")
    }
    
    private var userChatsReference: DatabaseReference {
        return rootReference.child("user_chats")
    }
    
    private var currentUserChatsReference: DatabaseReference {
        return rootReference.child("user_chats").child(currentUser.id)
    }
    
    public func createNewChat(with recipient : User) -> String {
        let newChatRef = chatsReference.childByAutoId()
        let membersRef = newChatRef.child("members")
        
        let chatID = newChatRef.key
        
        membersRef.child(recipient.id).setValue(recipient.name)
        membersRef.child(currentUser.id).setValue(currentUser.name)
        
        currentUserChatsReference.child(chatID).setValue(true)
        userChatsReference.child(recipient.id).child(chatID).setValue(true)
        
        return chatID
    }
    
    public func getChats(completion: @escaping ([String: Chat]) -> ()) {
        currentUserChatsReference.observe(.value) { snapshot in
            guard let chatsKeyDict = snapshot.value as? [String: Any] else { return }
            for chatID in chatsKeyDict.keys {
                self.chatsReference.child(chatID).observe(.value) { snapshot in
                    guard let chatDict = snapshot.value as? [String: Any] else { return }
                    if let chat = Chat(with: chatDict) {
                        completion([chatID:chat])
                    }
                }
            }
        }
    }
    
    public func chatUpdated(completion: @escaping (Bool) -> ()) {
        chatsReference.observe(.childChanged) { snapshot in
            
        }
    }
}
