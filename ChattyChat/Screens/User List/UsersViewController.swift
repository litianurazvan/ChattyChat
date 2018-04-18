//
//  UsersViewController.swift
//  ChattyChat
//
//  Created by Razvan Litianu on 14/03/2018.
//  Copyright © 2018 Razvan Litianu. All rights reserved.
//

import UIKit
import Firebase

class UsersViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
            tableView.register(UINib(nibName: "UserTableViewCell", bundle: nil), forCellReuseIdentifier: "UserCell")
        }
    }
    
    var users = [User]()
    
    var didSelectUser: (User) -> () = { _ in }
    
    var rootReference = Database.database().reference()
    var usersReference: DatabaseReference {
        return rootReference.child("users")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usersReference.observe(.childAdded) { [weak self] snapshot in
            guard var dictionary = snapshot.value as? [String: Any] else { return }
            dictionary["user_id"] = snapshot.key
            
            guard let user = User(dictionary: dictionary) else { return }
            
            self?.users.append(user)
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        
    }
}

extension UsersViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as? UserTableViewCell else { return UITableViewCell() }
        
        let user = users[indexPath.row]
        
        cell.nameLabel.text = user.name
        cell.emailLabel.text = user.email
        cell.profileImageView.loadImageFromUrl(user.profileImageUrlString, defaultImage: #imageLiteral(resourceName: "default_user"))
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectUser(users[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
}
