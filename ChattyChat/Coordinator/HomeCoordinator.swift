//
//  HomeCoordinator.swift
//  ChattyChat
//
//  Created by Razvan Litianu on 16/03/2018.
//  Copyright © 2018 Razvan Litianu. All rights reserved.
//

import UIKit

class HomeCoordinator: CoordinatorType {
    var rootNavigationController: UINavigationController
    var contextNavigationController: UINavigationController!
    
    var homeController: HomeViewController!
    
    weak var delegate: HomeCoordinatorDelegate?
    
    var userManager: UserManager!
    
    lazy var chatService = ChatService(user: userManager.currentUser!)
    
    init(with navigationController: UINavigationController) {
        rootNavigationController = navigationController
    }
    
    func start() {
        self.homeController = self.storyboard.instantiateViewController(HomeViewController.self)
        let viewModel = HomeViewModel(with: userManager, chatService: chatService)
        
        self.homeController.viewModel = viewModel
        self.homeController.userSignedOut = userSignedOut
        self.homeController.showUsers = showUsers
        self.homeController.showChatWithID = showChatWithID
        
        contextNavigationController = UINavigationController(rootViewController: homeController)
        rootNavigationController.present(contextNavigationController, animated: false, completion: nil)
    }
    
    
    func showChatWithID(_ id: String) {
        guard let userID = userManager.currentUserID else { return }
        let chatController = ChatViewController(chatID: id)
        chatController.currentUserID = userID
        chatController.chatViewModel = ChatViewModel(userManager: userManager)
        
        contextNavigationController.show(chatController, sender: self)
    }
    
    private func didSelectUser(_ user: User) {
        contextNavigationController.dismiss(animated: true) {
            self.homeController.didSelectUser(user)
        }
    }
    
    private func showUsers() {
        let usersController = storyboard.instantiateViewController(UsersViewController.self)
        usersController.didSelectUser = didSelectUser
        contextNavigationController.present(usersController, animated: true, completion: nil)
    }
    
    private func userSignedOut() {
        self.delegate?.homeDidFinishCoordinating(self)
    }
}
