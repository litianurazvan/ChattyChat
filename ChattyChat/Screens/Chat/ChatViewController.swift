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
            messagesTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "MessageCell")
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
    
    var sortedMessages: [Message] {
        return messages.sorted { $0.timeStamp > $1.timeStamp }
    }
    
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
        messagesTableView.rowHeight = UITableViewAutomaticDimension
        messagesTableView.estimatedRowHeight = 140
        messagesTableView.transform = CGAffineTransform(rotationAngle: (-.pi))
        messagesTableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, messagesTableView.bounds.size.width - 10)
        
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
        return sortedMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell =  tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as? MessageCell else { return  UITableViewCell() }
        cell.transform = CGAffineTransform(rotationAngle: (-.pi))
        let text = sortedMessages[indexPath.row].content
        cell.messageLabel.text = text
        let size = estimatedSizeForText(text: text)

        let screenWidth = UIScreen.main.bounds.width
        if size.width < screenWidth * 0.75 {
            cell.messageLabelWidth.constant = size.width + 17
        }
        return cell
    }

    func estimatedSizeForText(text: String) -> CGSize {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [.font: UIFont.systemFont(ofSize: 17)], context: nil).size
    }
}
