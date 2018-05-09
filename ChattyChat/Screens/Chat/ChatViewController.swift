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
    
    var chatID: String
    var chatViewModel: ChatViewModel!
    
    init(chatID: String) {
        self.chatID = chatID
        super.init(nibName: "ChatViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var currentUserID: String!
    
    var rootReference = Database.database().reference()

    var chatMessages: DatabaseReference { return rootReference.child("chat-messages").child(chatID) }
    var chatMessagesHandler: DatabaseHandle?
    
    var chatReference: DatabaseReference {
        return rootReference.child("chats").child(chatID)
    }
    
    var observerShowKeyboard: NSObjectProtocol!
    var observerHideKeyboard: NSObjectProtocol!
    
    var messages = [Message]()
    
    var sortedMessages: [Message] {
        return messages.sorted { $0.timeStamp > $1.timeStamp }
    }
    
    func getAllMessagesForCurrentChat(completion: @escaping (Bool) -> ()) {
        chatMessagesHandler = chatMessages.observe(.childAdded) { [unowned self] snapshot in
            guard let messageDict = snapshot.value as? [String: Any],
                let message = Message(from: messageDict) else {
                    completion(false)
                    return
            }
            self.messages.append(message)
            completion(true)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        messagesTableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, messagesTableView.bounds.size.width - 10)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "temp chat name"
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getAllMessagesForCurrentChat { [unowned self] success in
            if success {
                self.messagesTableView.reloadData()
            }
        }
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        chatMessages.removeObserver(withHandle: chatMessagesHandler!)
        
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.removeObserver(self)
    }
    
    private func send(message: String) {
        
        let time = NSDate().timeIntervalSince1970
        let messageDict: [String : Any] = ["content": message,
                                       "sender_id": currentUserID,
                                       "timestamp": time
        ]
        
        let chat: [String: Any] = ["lastMessage": message,
                                   "timestamp": time
        ]
        
        chatReference.updateChildValues(chat)
        
        let messageChild =  chatMessages.childByAutoId()
        messageChild.setValue(messageDict)
        
        messageTextField.text = nil
    }
    
    @IBAction func onSendButtonPress(_ sender: UIButton) {
        guard let content = messageTextField.text, !content.isEmpty else { return }
        send(message: content)
    }
}

extension ChatViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let content = messageTextField.text else { return false }
        send(message: content)
        return true
    }
}


// MARK:- Keyboard handling

extension ChatViewController {
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size else { return }
        let keyboardHeight = keyboardSize.height
        messageStackBottomContraint.constant = keyboardHeight
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        messageStackBottomContraint.constant = 0
    }
    
}

// MARK:- TableView Datasource & Delegate

extension ChatViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell =  tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as? MessageCell else { return  UITableViewCell() }
        cell.transform = CGAffineTransform(rotationAngle: (-.pi))
        
        let message = sortedMessages[indexPath.row]
        cell.messageLabel.text = message.content
        cell.style = message.senderID == currentUserID ? .sender : .receiver
        
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
