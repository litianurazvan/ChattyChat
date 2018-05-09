//
//  ChatService.swift
//  ChattyChat
//
//  Created by Razvan Litianu on 25/04/2018.
//  Copyright © 2018 Razvan Litianu. All rights reserved.
//

import Firebase

enum Reference {
    case root
    case chats
    case userChats
    case userChatsWithID(userID: String)
    
    var databaseReference: Firebase.DatabaseReference {
        switch self {
        case .root:
            return Database.database().reference()
        case .chats:
            return Database.database().reference().child("chats")
        case .userChats:
            return Database.database().reference().child("user_chats")
        case let .userChatsWithID(userID):
            return Database.database().reference().child("user_chats").child(userID)
        }
    }
}

class ChatService {
    private var currentUser: User
    private var chatLiveObject: ChatLiveObject
    
    weak var observer: ChatDetailsObserver?
    
    var chats = [String: Chat]() {
        didSet {
            observer?.chatService(self, didDownload: chats)
        }
    }

    private func getChatInfoForID(_ chatID: String, completion: @escaping ((Chat) -> ())) {
        chatsReference.child(chatID).observe(.value) { snapshot in
            guard let chatDict = snapshot.value as? [String: Any] else { return }
            if let chat = Chat(with: chatDict) {
                completion(chat)
            }
        }
    }

    init(user: User) {
        currentUser = user
        chatLiveObject = ChatLiveObject(currentUserChatsReference: .userChatsWithID(userID: user.id))
        chatLiveObject.observer = self
    }
    
    private var chatsReference: DatabaseReference {
        return Reference.chats.databaseReference
    }
    
    private var userChatsReference: DatabaseReference {
        return Reference.userChats.databaseReference
    }

    private var currentUserChatsReference: DatabaseReference {
        return Reference.userChatsWithID(userID: currentUser.id).databaseReference
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
}

extension ChatService: UserChatListObserver {
    func chatLiveObject(_ liveObject: ChatLiveObject, didChangeChatIDList chatIDList: [String]) {
        chatIDList.forEach { id in
            getChatInfoForID(id) { [unowned self] chat in
                self.chats[id] = chat
            }
        }
    }
}

