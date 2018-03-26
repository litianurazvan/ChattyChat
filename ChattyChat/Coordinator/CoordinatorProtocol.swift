//
//  CoordinatorProtocol.swift
//  ChattyChat
//
//  Created by Razvan Litianu on 16/03/2018.
//  Copyright © 2018 Razvan Litianu. All rights reserved.
//

import UIKit

protocol CoordinatorType: AnyObject {
    var navigationController: UINavigationController { get set }
    func start()
}

extension CoordinatorType {
    var storyboard: UIStoryboard {
        return UIStoryboard(storyboard: .main, bundle: nil)
    }
}
