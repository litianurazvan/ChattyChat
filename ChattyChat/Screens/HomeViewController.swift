//
//  HomeViewController.swift
//  FirebaseLogin
//
//  Created by Razvan Litianu on 09/03/2018.
//  Copyright © 2018 Razvan Litianu. All rights reserved.
//

import UIKit
import Firebase

class HomeViewController: UIViewController {
    
    @IBOutlet weak var chatTableView: UITableView! {
        didSet {
            chatTableView.delegate = self
            chatTableView.dataSource = self
            chatTableView.register(UINib(nibName: "ChatroomCell", bundle: nil), forCellReuseIdentifier: "ChatroomCell")
        }
    }
    
    var userSignedOut: ()->() = { }
    var showUsers: () -> () = { }
    var showChatForUser: (User) -> () = { _ in }
    
    var rootReference = Database.database().reference()
    
    var messagesReference: DatabaseReference {
        return rootReference.child("messages")
    }
    
    var userMessagesReference: DatabaseReference {
        return rootReference.child("user-messages")
    }
    
    var usersReference: DatabaseReference {
        return rootReference.child("users")
    }
    
    var currentUserMessagesReference: DatabaseReference {
        let currentUserID = Auth.auth().currentUser!.uid
        return userMessagesReference.child(currentUserID)
    }
    
    var chats = [String: [Message]]()
    var users = [User]()
    
    fileprivate func getAllChats(completion: @escaping (Bool) -> ()) {
        
        currentUserMessagesReference.observe(.childAdded) { [unowned self] snapshot in
            let recipientID = snapshot.key
            self.chats[recipientID] = [Message]()
            
            let ref = self.currentUserMessagesReference.child(recipientID)
            ref.observe(.childAdded) { snapshot in
                let messageID = snapshot.key
                let messageRef = self.messagesReference.child(messageID)
                messageRef.observe(.value) { [unowned self] snapshot in
                    guard let messageDict = snapshot.value as? [String: Any], let message = Message(from: messageDict) else { return }
                    self.chats[recipientID]?.append(message)
                    completion(true)
                }
            }
        }
    }
    
    func getAllRecipients(completion: @escaping (Bool) -> ()) {
        
        currentUserMessagesReference.observe(.childAdded) { [unowned self] snapshot in
            
            let recipientID = snapshot.key
            let userRef = self.usersReference.child(recipientID)
            
            userRef.observe(.value) { [unowned self] snapshot in
                guard var dictionary = snapshot.value as? [String: Any] else { return }
                dictionary["user_id"] = snapshot.key
                
                guard let user = User(dictionary: dictionary) else { return }
                
                self.users.append(user)
                completion(true)
            }
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getAllChats { finished in
            self.chatTableView.reloadData()
        }
        
        getAllRecipients { finished in
            self.chatTableView.reloadData()
        }
        
    }
    
    @IBAction func onSignOutButtonTap(_ sender: UIBarButtonItem) {
        do {
           try Auth.auth().signOut()
            userSignedOut()
        } catch let error {
            let alert = UIAlertController.alertWithTitle("Error", message: error.localizedDescription)
            present(alert, animated: true, completion: nil)
            return
        }
    }
    
    @IBAction func onComposeMessageButtonTap(_ sender: UIBarButtonItem) {
        showUsers()
    }
    
    var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("h:mm a")
        return dateFormatter
    }()
}


extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChatroomCell", for: indexPath) as? ChatroomCell else { return UITableViewCell() }
        let user = users[indexPath.row]
        let messages = chats[user.id]?.sorted(by: {$0.timeStamp < $1.timeStamp})
        
        cell.userName.text = user.name
        cell.userImageView.loadImageFromUrl(user.profileImageUrlString, defaultImage: #imageLiteral(resourceName: "default_user"))
        if let lastMessage = messages?.last {
            cell.lastMessage.text = lastMessage.content
            cell.timeSentLabel.text = dateFormatter.string(from: Date(timeIntervalSince1970: lastMessage.timeStamp))
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        showChatForUser(user)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
