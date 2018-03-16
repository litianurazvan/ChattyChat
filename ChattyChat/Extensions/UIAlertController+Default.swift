//
//  UIAlertController+Default.swift
//  FirebaseLogin
//
//  Created by Razvan Litianu on 12/03/2018.
//  Copyright © 2018 Razvan Litianu. All rights reserved.
//

import UIKit

extension UIAlertController {
    static func alertWithTitle(_ title: String, message: String) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        
        alertController.addAction(defaultAction)
        
        return alertController
    }
}
