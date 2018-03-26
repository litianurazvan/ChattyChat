//
//  LoginViewController.swift
//  FirebaseLogin
//
//  Created by Razvan Litianu on 09/03/2018.
//  Copyright © 2018 Razvan Litianu. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController, SegueHandlerType {

    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var authetificationSucceded: ()->() = { }
    

    @IBAction func onLoginButtonTap(_ sender: UIButton) {
        guard let email = userNameTextField.text else {
            let alert = UIAlertController.alertWithTitle("Please enter email", message: "Missing email")
            present(alert, animated: true, completion: nil)
            return
        }
        
        guard let password = passwordTextField.text else {
            let alert = UIAlertController.alertWithTitle("Please enter Password", message: "Missing password")
            present(alert, animated: true, completion: nil)
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] user, error in
            if let error = error {
                let alert = UIAlertController.alertWithTitle("Error", message: error.localizedDescription)
                self?.present(alert, animated: true, completion: nil)
            }
            
            if user != nil {
                self?.authetificationSucceded()
            }
        }
    }
}
