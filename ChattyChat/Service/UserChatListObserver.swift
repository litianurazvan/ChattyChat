//
//  UserChatListObserver.swift
//  ChattyChat
//
//  Created by Razvan Litianu on 09/05/2018.
//  Copyright © 2018 Razvan Litianu. All rights reserved.
//

import Foundation

protocol UserChatListObserver: AnyObject {
    func chatLiveObject(_ liveObject: ChatLiveObject, didChangeChatIDList chatList: [String])
}
