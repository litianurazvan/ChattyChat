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
        
        rootReference = Database.database().reference()
        usersReference = rootReference.child("users")
        
        usersReference.observe(.childAdded) { snapshot in
            guard let dictionary = snapshot.value as? [String: Any],
                let user = User(dictionary: dictionary) else { return }
            
            self.users.append(user)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}

extension UsersViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath)
        
        let user = users[indexPath.row]
        
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        
        return cell
    }
}
