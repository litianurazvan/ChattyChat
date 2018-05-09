//
//  ChatLiveObject.swift
//  ChattyChat
//
//  Created by Razvan Litianu on 08/05/2018.
//  Copyright © 2018 Razvan Litianu. All rights reserved.
//

import Firebase

class ChatLiveObject {
    typealias ChatIDList = [String]
    
    private var chats = ChatIDList() {
        didSet {
            observer?.chatLiveObject(self, didChangeChatIDList: chats)
        }
    }
    
    weak var observer: UserChatListObserver?
    
    let currentUserChatsReference: DatabaseReference
    
    init(currentUserChatsReference: Reference) {
        self.currentUserChatsReference = currentUserChatsReference.databaseReference
        
        getUserChats { [unowned self] userChats in
            self.chats.append(contentsOf: userChats.keys)
        }
    }
    
    
    func getUserChats(completion: @escaping ([String: Any]) -> ()) {
        currentUserChatsReference.observe(.value) { snapshot in
            guard let userChats = snapshot.value as? [String: Any] else { return }
            completion(userChats)
        }
    }
}
