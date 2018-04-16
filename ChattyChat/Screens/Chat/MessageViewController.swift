//
//  MessageViewController.swift
//  ChattyChat
//
//  Created by Razvan Litianu on 16/04/2018.
//  Copyright © 2018 Razvan Litianu. All rights reserved.
//

import UIKit

class MessageViewController: UIViewController {
    
    @IBOutlet weak var messageStackBottomContraint: NSLayoutConstraint!
    
    var user: User! {
        didSet {
            navigationItem.title = user.name
        }
    }
    @IBOutlet weak var messageTextField: UITextField!
    
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

    func keyboardWillShow(_ notification: Notification) {
        guard let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size else { return }
        let keyboardHeight = keyboardSize.height
        messageStackBottomContraint.constant = keyboardHeight
    }
    
    func keyboardWillHide(_ notification: Notification) {
        messageStackBottomContraint.constant = 0
    }
    
    @IBAction func onSendButtonPress(_ sender: UIButton) {
        messageTextField.resignFirstResponder()
    }
}
