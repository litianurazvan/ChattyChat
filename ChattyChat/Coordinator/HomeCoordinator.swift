//
//  HomeCoordinator.swift
//  ChattyChat
//
//  Created by Razvan Litianu on 16/03/2018.
//  Copyright © 2018 Razvan Litianu. All rights reserved.
//

import UIKit

class HomeCoordinator: CoordinatorType {
    var navigationController: UINavigationController
    weak var delegate: HomeCoordinatorDelegate?
    
    init(with navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let homeController = storyboard.instantiateViewController(HomeViewController.self)
        homeController.userSignedOut = self.userSignedOut
        homeController.showUsers = self.showUsers
        navigationController.childViewControllers.forEach { vc in
            vc.removeFromParentViewController()
        }
        navigationController.setViewControllers([homeController], animated: true)
    }
    
    private func didSelect(_ user: User) {
        navigationController.dismiss(animated: true) {
            let messageController = MessageViewController()
            messageController.user = user
            self.navigationController.pushViewController(messageController, animated: true)
        }
    }
    
    private func showUsers() {
        let usersController = storyboard.instantiateViewController(UsersViewController.self)
        usersController.didSelectUser = didSelect(_:)
        navigationController.present(usersController, animated: true, completion: nil)
    }
    
    private func userSignedOut() {
        self.delegate?.homeDidFinishCoordinating(self)
    }
}
