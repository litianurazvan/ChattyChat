//
//  AppCoordinator.swift
//  ChattyChat
//
//  Created by Razvan Litianu on 16/03/2018.
//  Copyright © 2018 Razvan Litianu. All rights reserved.
//

import UIKit
import Firebase

class AppCoordinator: CoordinatorType {
    var delegate: RegistrationCoordinatorDelegate?
    
    var navigationController: UINavigationController
    var childCoordinators = [CoordinatorType]()
    
    init(with navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    fileprivate func startRegistrationFlow() {
        let registrationCoordinator = RegistrationCoordinator(with: navigationController)
        registrationCoordinator.delegate = self
        childCoordinators.append(registrationCoordinator)
        registrationCoordinator.start()
    }
    
    fileprivate func startHomePageFlow() {
        let homeCoordinator = HomeCoordinator(with: navigationController)
        homeCoordinator.delegate = self
        childCoordinators.append(homeCoordinator)
        homeCoordinator.start()
    }
    
    func start() {
        if Auth.auth().currentUser == nil {
            startRegistrationFlow()
        } else {
            startHomePageFlow()
        }
    }
}

extension AppCoordinator: RegistrationCoordinatorDelegate {
    func registrationDidFinishCoordinating(_ coordinator: CoordinatorType) {
        childCoordinators = childCoordinators.filter { $0 !== coordinator }
        self.startHomePageFlow()
    }
}

extension AppCoordinator: HomeCoordinatorDelegate {
    func homeDidFinishCoordinating(_ coordinator: CoordinatorType) {
        childCoordinators = childCoordinators.filter { $0 !== coordinator }
        self.startRegistrationFlow()
    }
}
