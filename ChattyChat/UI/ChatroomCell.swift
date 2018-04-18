//
//  ChatroomCell.swift
//  ChattyChat
//
//  Created by Razvan Litianu on 18/04/2018.
//  Copyright © 2018 Razvan Litianu. All rights reserved.
//

import UIKit

class ChatroomCell: UITableViewCell {
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var lastMessage: UILabel!
    @IBOutlet weak var timeSentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        userImageView.clipsToBounds = true
        userImageView.layer.cornerRadius = userImageView.frame.size.width / 2
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        userImageView.image = nil
    }
}
