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
    
    @IBAction func onSignOutButtonTap(_ sender: UIBarButtonItem) {
        do {
           try Auth.auth().signOut()
        } catch let error {
            let alert = UIAlertController.alertWithTitle("Error", message: error.localizedDescription)
            present(alert, animated: true, completion: nil)
            return
        }
        
        let storyboard = UIStoryboard(storyboard: .main, bundle: nil)
        let initial = storyboard.instantiateInitialViewController()
        UIApplication.shared.keyWindow?.rootViewController = initial
    }
}
