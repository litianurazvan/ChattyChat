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
        }
    }
    
    var userSignedOut: ()->() = { }
    var showUsers: () -> () = { }
    
    var rootReference = Database.database().reference()
    
    var messagesReference: DatabaseReference {
        return rootReference.child("messages")
    }
    
    var userMessagesReference: DatabaseReference {
        return rootReference.child("user-messages")
    }
    
    var currentUserMessagesReference: DatabaseReference {
        let currentUserID = Auth.auth().currentUser!.uid
        return userMessagesReference.child(currentUserID)
    }
    
    var messages = [Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentUserMessagesReference.observe(.childAdded) { snapshot in
            let messageID = snapshot.key
            let messageRef = self.messagesReference.child(messageID)
            messageRef.observe(.value) { snapshot in
                guard let messageDict = snapshot.value as? [String: Any], let message = Message(from: messageDict) else { return }
                self.messages.append(message)
                DispatchQueue.main.async {
                    self.chatTableView.reloadData()
                }
            }
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
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = messages[indexPath.row].content
        return cell

    }
}
