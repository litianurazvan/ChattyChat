//
//  ChatViewController.swift
//  ChattyChat
//
//  Created by Razvan Litianu on 16/04/2018.
//  Copyright © 2018 Razvan Litianu. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController: UIViewController {
    
    @IBOutlet weak var messageTextField: UITextField! {
        didSet {
            messageTextField.delegate = self
        }
    }
    
    @IBOutlet weak var messageStackBottomContraint: NSLayoutConstraint!
    
    @IBOutlet weak var messagesTableView: UITableView! {
        didSet {
            messagesTableView.delegate = self
            messagesTableView.dataSource = self
        }
    }
    
    var user: User! {
        didSet {
            navigationItem.title = user.name
        }
    }
    
    var loggedInUserID: String {
        return Auth.auth().currentUser!.uid
    }
    
    var rootReference = Database.database().reference()
    var messagesReference: DatabaseReference {
        return rootReference.child("messages")
    }
    var userMessagesReference: DatabaseReference {
        return rootReference.child("user-messages")
    }
    
    var chatMessages: DatabaseReference {
        return userMessagesReference.child(loggedInUserID).child(user.id)
    }
    
    var observerShowKeyboard: NSObjectProtocol!
    var observerHideKeyboard: NSObjectProtocol!
    
    var messages = [Message]()
    
    func getAllMessagesForCurrentChat(completion: @escaping (Bool) -> ()) {
        chatMessages.observe(.childAdded) { snapshot in
            let messageID = snapshot.key
            let messageRef = self.messagesReference.child(messageID)
            messageRef.observe(.value) { [unowned self] snapshot in
                guard let messageDict = snapshot.value as? [String: Any], let message = Message(from: messageDict) else { return }
                self.messages.append(message)
                completion(true)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getAllMessagesForCurrentChat { finished in
            self.messagesTableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        observerShowKeyboard = NotificationCenter.default.addObserver(forName: .UIKeyboardWillShow, object: nil, queue: .main, using: keyboardWillShow(_:))
        observerHideKeyboard = NotificationCenter.default.addObserver(forName: .UIKeyboardWillHide, object: nil, queue: .main, using: keyboardWillHide(_:))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(observerShowKeyboard)
        NotificationCenter.default.removeObserver(observerHideKeyboard)
    }
    
    @IBAction func onSendButtonPress(_ sender: UIButton) {
        guard let content = messageTextField.text else { return }
        let message: [String : Any] = ["content": content,
                                       "recipient_id": user.id,
                                       "sender_id": loggedInUserID,
                                       "timestamp": NSDate().timeIntervalSince1970
        ]
        let messageChild =  messagesReference.childByAutoId()
        messageChild.setValue(message)
        
        userMessagesReference.child(loggedInUserID).child(user.id).updateChildValues([messageChild.key: 1])
        userMessagesReference.child(user.id).child(loggedInUserID).updateChildValues([messageChild.key: 1])
        
        
        messageTextField.text = nil
    }
}

extension ChatViewController: UITextFieldDelegate {
    
}


// MARK:- Keyboard handling

extension ChatViewController {
    func keyboardWillShow(_ notification: Notification) {
        guard let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size else { return }
        let keyboardHeight = keyboardSize.height
        messageStackBottomContraint.constant = keyboardHeight
    }
    
    func keyboardWillHide(_ notification: Notification) {
        messageStackBottomContraint.constant = 0
    }
    
}

extension ChatViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  UITableViewCell()
        cell.textLabel?.text = messages[indexPath.row].content
        return cell
    }
    
    
}
