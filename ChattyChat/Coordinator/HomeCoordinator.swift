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
        navigationController.childViewControllers.forEach { vc in
            vc.removeFromParentViewController()
        }
        navigationController.setViewControllers([homeController], animated: true)
    }
    
    func userSignedOut() {
        self.delegate?.homeDidFinishCoordinating(self)
    }
}
