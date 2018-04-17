//
//  MessageViewController.swift
//  ChattyChat
//
//  Created by Razvan Litianu on 16/04/2018.
//  Copyright © 2018 Razvan Litianu. All rights reserved.
//

import UIKit
import Firebase

class MessageViewController: UIViewController {
    
    @IBOutlet weak var messageTextField: UITextField! {
        didSet {
            messageTextField.delegate = self
        }
    }
    
    @IBOutlet weak var messageStackBottomContraint: NSLayoutConstraint!
    
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
    
    var observerShowKeyboard: NSObjectProtocol!
    var observerHideKeyboard: NSObjectProtocol!
    
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
                                       "receiver_id": user.id,
                                       "sender_id": loggedInUserID,
                                       "timestamp": NSDate().timeIntervalSince1970
        ]
        messagesReference.childByAutoId().setValue(message)
        messageTextField.text = nil
    }
}

extension MessageViewController: UITextFieldDelegate {
    
}


// MARK:- Keyboard handling

extension MessageViewController {
    func keyboardWillShow(_ notification: Notification) {
        guard let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size else { return }
        let keyboardHeight = keyboardSize.height
        messageStackBottomContraint.constant = keyboardHeight
    }
    
    func keyboardWillHide(_ notification: Notification) {
        messageStackBottomContraint.constant = 0
    }
    
}
