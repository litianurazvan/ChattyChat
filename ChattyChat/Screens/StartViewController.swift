//
//  StartViewController.swift
//  FirebaseLogin
//
//  Created by Razvan Litianu on 09/03/2018.
//  Copyright © 2018 Razvan Litianu. All rights reserved.
//

import UIKit
import Firebase

class StartViewController: UIViewController, SegueHandlerType {
    
    var showLogin: ()->() = { }
    var showSignUp: ()->() = { }
    
    @IBAction func onLoginButtonTap(_ sender: UIButton) {
        showLogin()
    }
    @IBAction func onSignUpButtonTap(_ sender: UIButton) {
        showSignUp()
    }
}

