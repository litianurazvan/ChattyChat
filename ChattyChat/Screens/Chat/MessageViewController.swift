//
//  MessageViewController.swift
//  ChattyChat
//
//  Created by Razvan Litianu on 16/04/2018.
//  Copyright © 2018 Razvan Litianu. All rights reserved.
//

import UIKit

class MessageViewController: UIViewController {
    
    var user: User! {
        didSet {
            navigationItem.title = user.name
        }
    }
}
