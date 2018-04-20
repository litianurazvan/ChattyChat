//
//  MessageCell.swift
//  ChattyChat
//
//  Created by Razvan Litianu on 18/04/2018.
//  Copyright © 2018 Razvan Litianu. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell {

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var bubbleView: UIView!
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var bubbleViewWidth: NSLayoutConstraint!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        messageLabel.text = nil
    }
}
