//
//  HomeViewController.swift
//  FirebaseLogin
//
//  Created by Razvan Litianu on 09/03/2018.
//  Copyright © 2018 Razvan Litianu. All rights reserved.
//

import UIKit
import Firebase

class HomeViewController: UIViewController {
    
    @IBOutlet weak var chatTableView: UITableView! {
        didSet {
            chatTableView.delegate = self
            chatTableView.dataSource = self
            chatTableView.register(UINib(nibName: "ChatroomCell", bundle: nil), forCellReuseIdentifier: "ChatroomCell")
        }
    }
    
    var userSignedOut: ()->() = { }
    var showUsers: () -> () = { }
    var showChatWithID: (String) -> () = { _ in }
    
    func chatsDidChange() {
        chatTableView.reloadData()
    }
    
    func didSelectUser(_ user: User) {
        let id = viewModel.getChatID(for: user) ?? viewModel.getNewChatID(for: user)
        showChatWithID(id)
    }
    
    var viewModel: HomeViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.chatDidChange = chatsDidChange
        
        viewModel.getCurrentUserInfo { result in
            switch result {
            case let .success(user):
                DispatchQueue.main.async {
                    self.navigationItem.title = user.name
                }
            case let .failure(error):
                print(error)
            }
        }
        
        self.navigationItem.title = viewModel.currentUserName
    }
    
    @IBAction func onSignOutButtonTap(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
            userSignedOut()
        } catch let error {
            let alert = UIAlertController.alertWithTitle("Error", message: error.localizedDescription)
            present(alert, animated: true, completion: nil)
            return
        }
    }
    
    @IBAction func onComposeMessageButtonTap(_ sender: UIBarButtonItem) {
        showUsers()
    }
}


extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.sortedChatIDs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChatroomCell", for: indexPath) as? ChatroomCell else { return UITableViewCell() }
        guard let cellViewModel = viewModel.chatCellViewModel(for: indexPath) else { return UITableViewCell() }
        
        cell.userName.text = cellViewModel.chatTitle
        cell.userImageView.loadImageFromUrl(cellViewModel.imageURL, defaultImage: #imageLiteral(resourceName: "default_user"))
        cell.lastMessage.text = cellViewModel.lastMessage
        cell.timeSentLabel.text = cellViewModel.timeSent
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chatID = viewModel.sortedChatIDs[indexPath.row]
        showChatWithID(chatID)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
