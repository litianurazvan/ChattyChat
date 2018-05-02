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
    
    func didSelectUser(_ user: User) {
        let id = viewModel.getChatID(for: user) ?? viewModel.getNewChatID(for: user)
        showChatWithID(id)
    }
    
    var viewModel: HomeViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.getSortedChatInfo { success in
            if success {
                self.chatTableView.reloadData()
            }
        }
        
//        viewModel.getCurrentUserInfo { result in
//            switch result {
//            case let .success(user):
//                DispatchQueue.main.async {
//                    self.navigationItem.title = user.name
//                }
//            case let .failure(error):
//                print(error)
//            }
//        }
        
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
    
    var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("h:mm a")
        return dateFormatter
    }()
}


extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.sortedChatIDs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChatroomCell", for: indexPath) as? ChatroomCell else { return UITableViewCell() }
        
        let chatID = viewModel.sortedChatIDs[indexPath.row]
        guard let chat = viewModel.chatForID(chatID) else { return UITableViewCell() }
        
        cell.userName.text = chat.members.values.filter{ $0 != viewModel.currentUserName }.reduce("", {$0 + $1})
//        cell.userImageView.loadImageFromUrl(chat.recipient.profileImageUrlString, defaultImage: #imageLiteral(resourceName: "default_user"))
        cell.lastMessage.text = chat.lastMessage
        cell.timeSentLabel.text = dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(chat.timestamp ?? 0)))
        
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
