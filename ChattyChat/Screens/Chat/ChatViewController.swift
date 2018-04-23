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
            messagesTableView.rowHeight = UITableViewAutomaticDimension
            messagesTableView.estimatedRowHeight = 140
            messagesTableView.transform = CGAffineTransform(rotationAngle: (-.pi))
        }
    }
    
    var user: User
    
    init(user: User) {
        self.user = user
        super.init(nibName: "ChatViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        messagesTableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, messagesTableView.bounds.size.width - 10)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = user.name
        
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
    
    private func sendMessage() {
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
    
    @IBAction func onSendButtonPress(_ sender: UIButton) {
        sendMessage()
    }
}

extension ChatViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendMessage()
        return true
    }
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
        
        let message = sortedMessages[indexPath.row]
        cell.messageLabel.text = message.content
        cell.messageLabel.textColor = message.senderID == loggedInUserID ? #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        cell.bubbleView.backgroundColor = message.senderID == loggedInUserID ? #colorLiteral(red: 0.2352941176, green: 0.5882352941, blue: 0.9490196078, alpha: 1) : #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        cell.stackView.alignment = message.senderID == loggedInUserID ? .trailing : .leading
        
        let size = estimatedSizeForText(text: message.content)
        let screenWidth = UIScreen.main.bounds.width
        
        cell.bubbleViewWidth.constant = size.width < screenWidth * 0.75 ? size.width + 17 : screenWidth * 0.75
        
        return cell
    }

    func estimatedSizeForText(text: String) -> CGSize {
        let screenWidth = UIScreen.main.bounds.width
        let size = CGSize(width: screenWidth * 0.75, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [.font: UIFont.systemFont(ofSize: 17)], context: nil).size
    }
}
