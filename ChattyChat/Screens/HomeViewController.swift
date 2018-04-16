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
    
    var userSignedOut: ()->() = { }
    var showUsers: () -> () = { }
    
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
