//
//  SegueHandlerType.swift
//  FirebaseLogin
//
//  Created by Razvan Litianu on 09/03/2018.
//  Copyright © 2018 Razvan Litianu. All rights reserved.
//

import UIKit

enum SegueIdentifier: String {
    case startToLogin
    case startToHome
    case startToSignUp
    case logInToHome
    case signUpToHome
    
    var capitalised: String {
       return self.rawValue.firstUpperCased!
    }
}

protocol SegueHandlerType { }

extension SegueHandlerType where Self: UIViewController {
    func performSegueWithIdentifier(_ identifier: SegueIdentifier, sender: Any?) {
        performSegue(withIdentifier: identifier.capitalised, sender: sender)
    }
}
