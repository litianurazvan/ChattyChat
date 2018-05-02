//
//  RegistrationCoordinator.swift
//  ChattyChat
//
//  Created by Razvan Litianu on 16/03/2018.
//  Copyright © 2018 Razvan Litianu. All rights reserved.
//

import UIKit

class RegistrationCoordinator: CoordinatorType {
    var navigationController: UINavigationController
    weak var delegate: RegistrationCoordinatorDelegate?
    
    var userManager: UserManager!
    
    init(with navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let startController = storyboard.instantiateViewController(StartViewController.self)
        startController.showLogin = self.showLogin
        startController.showSignUp = self.showSignUp
        navigationController.childViewControllers.forEach { vc in
            vc.removeFromParentViewController()
        }
        navigationController.setViewControllers([startController], animated: true)
    }
    
    func showLogin() {
        let loginController = storyboard.instantiateViewController(LoginViewController.self)
        loginController.userManager = userManager
        loginController.authetificationSucceded = self.authentificationSucceded
        navigationController.show(loginController, sender: self)
    }
    
    func showSignUp() {
        let signUpController = storyboard.instantiateViewController(SignUpViewController.self)
        signUpController.userManager = userManager
        signUpController.authetificationSucceded = self.authentificationSucceded
        navigationController.show(signUpController, sender: self)
    }
    
    func authentificationSucceded() {
        delegate?.registrationDidFinishCoordinating(self)
    }
}
