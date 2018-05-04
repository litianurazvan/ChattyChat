//
//  RegistrationCoordinator.swift
//  ChattyChat
//
//  Created by Razvan Litianu on 16/03/2018.
//  Copyright © 2018 Razvan Litianu. All rights reserved.
//

import UIKit

class RegistrationCoordinator: CoordinatorType {
    var rootNavigationController: UINavigationController
    var contextNavigationController: UINavigationController!
    
    weak var delegate: RegistrationCoordinatorDelegate?
    
    var userManager: UserManager!
    
    init(with navigationController: UINavigationController) {
        rootNavigationController = navigationController
    }
    
    func start() {
        let startController = storyboard.instantiateViewController(StartViewController.self)
        startController.showLogin = showLogin
        startController.showSignUp = showSignUp
        
        contextNavigationController = UINavigationController(rootViewController: startController)
        rootNavigationController.present(contextNavigationController, animated: false, completion: nil)
    }
    
    func showLogin() {
        let loginController = storyboard.instantiateViewController(LoginViewController.self)
        loginController.userManager = userManager
        loginController.authetificationSucceded = authentificationSucceded
        contextNavigationController.show(loginController, sender: self)
    }
    
    func showSignUp() {
        let signUpController = storyboard.instantiateViewController(SignUpViewController.self)
        signUpController.userManager = userManager
        signUpController.authetificationSucceded = authentificationSucceded
        contextNavigationController.show(signUpController, sender: self)
    }
    
    func authentificationSucceded() {
        delegate?.registrationDidFinishCoordinating(self)
    }
}
