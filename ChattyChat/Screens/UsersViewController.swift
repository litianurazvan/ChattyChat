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
    @IBOutlet weak var tableView: UITableView!
    
    var users = [User]()
    
    var rootReference: DatabaseReference!
    var usersReference: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: "UserTableViewCell", bundle: nil), forCellReuseIdentifier: "UserCell")
        
        rootReference = Database.database().reference()
        usersReference = rootReference.child("users")
        
        usersReference.observe(.childAdded) { [weak self] snapshot in
            guard let dictionary = snapshot.value as? [String: Any],
                let user = User(dictionary: dictionary) else { return }
            
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
}
