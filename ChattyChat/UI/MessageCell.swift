//
//  MessageCell.swift
//  ChattyChat
//
//  Created by Razvan Litianu on 18/04/2018.
//  Copyright © 2018 Razvan Litianu. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell {
    enum Style {
        case sender
        case receiver
    }
    
    var style: Style = .sender {
        didSet {
            configure(with: style)
        }
    }

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var bubbleView: UIView!
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var bubbleViewWidth: NSLayoutConstraint!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        messageLabel.text = nil
    }
    
    private func configure(with style: Style) {
        switch style {
        case .sender:
            messageLabel.textColor =  #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            bubbleView.backgroundColor =  #colorLiteral(red: 0.2352941176, green: 0.5882352941, blue: 0.9490196078, alpha: 1)
            stackView.alignment =  .trailing
        case .receiver:
            messageLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            bubbleView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            stackView.alignment = .leading
        }
    }
}
