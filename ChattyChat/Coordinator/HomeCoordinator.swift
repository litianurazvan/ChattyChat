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
    var homeController: HomeViewController!
    
    weak var delegate: HomeCoordinatorDelegate?
    
    var userManager: UserManager!
    
    lazy var chatService = ChatService(user: userManager.currentUser!)
    
    init(with navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        self.homeController = self.storyboard.instantiateViewController(HomeViewController.self)
        let viewModel = HomeViewModel(with: self.userManager, chatService: self.chatService)
        
        self.homeController.viewModel = viewModel
        self.homeController.userSignedOut = self.userSignedOut
        self.homeController.showUsers = self.showUsers
        self.homeController.showChatWithID = self.showChatWithID
        self.navigationController.childViewControllers.forEach { vc in
            vc.removeFromParentViewController()
        }
        self.navigationController.setViewControllers([self.homeController], animated: true)
    }
    
    
    func showChatWithID(_ id: String) {
        guard let userID = userManager.currentUserID else { return }
        let chatController = ChatViewController(chatID: id)
        chatController.currentUserID = userID
        chatController.chatViewModel = ChatViewModel(userManager: userManager)
        self.navigationController.pushViewController(chatController, animated: true)
    }
    
    private func didSelectUser(_ user: User) {
        navigationController.dismiss(animated: true) {
            self.homeController.didSelectUser(user)
        }
    }
    
    private func showUsers() {
        let usersController = storyboard.instantiateViewController(UsersViewController.self)
        usersController.didSelectUser = didSelectUser
        navigationController.present(usersController, animated: true, completion: nil)
    }
    
    private func userSignedOut() {
        self.delegate?.homeDidFinishCoordinating(self)
    }
}
