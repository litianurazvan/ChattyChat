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
    
    func downloadImage(from profileImageUrl: URL, completion: @escaping (UIImage?)->()) {
        URLSession.shared.dataTask(with: profileImageUrl, completionHandler: { data, urlResponse, error in
            if let error = error {
                print(error.localizedDescription)
                completion(nil)
            }
            
            let image = data.flatMap(UIImage.init)
            completion(image)
        }).resume()
    }
    
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
        cell.imageView?.image = #imageLiteral(resourceName: "default_user")
        
        if let profileImageUrlString = user.profileImage,
            let profileImageUrl = URL(string: profileImageUrlString) {
            downloadImage(from: profileImageUrl, completion: { image in
                DispatchQueue.main.async {
                    cell.imageView?.image = image ?? #imageLiteral(resourceName: "default_user")
                }
            })
        }
        return cell
    }
}
