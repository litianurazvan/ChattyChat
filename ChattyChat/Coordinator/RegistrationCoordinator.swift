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
    
    init(with navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        guard let startController = storyboard.instantiateViewController(StartViewController.self) as? StartViewController else { return }
        startController.showLogin = self.showLogin
        startController.showSignUp = self.showSignUp
        navigationController.childViewControllers.forEach { vc in
            vc.removeFromParentViewController()
        }
        navigationController.setViewControllers([startController], animated: true)
    }
    
    func showLogin() {
        guard let loginController = storyboard.instantiateViewController(LoginViewController.self) as? LoginViewController else { return }
        loginController.authetificationSucceded = self.authentificationSucceded
        navigationController.show(loginController, sender: self)
    }
    
    func showSignUp() {
        guard let signUpController = storyboard.instantiateViewController(SignUpViewController.self) as? SignUpViewController else { return }
        signUpController.authetificationSucceded = self.authentificationSucceded
        navigationController.show(signUpController, sender: self)
    }
    
    func authentificationSucceded() {
        delegate?.registrationDidFinishCoordinating(self)
    }
}
