//
//  UIStoryBoard+CustomInit.swift
//  FirebaseLogin
//
//  Created by Razvan Litianu on 12/03/2018.
//  Copyright © 2018 Razvan Litianu. All rights reserved.
//

import UIKit

enum Storyboard: String {
    case main
    
    var fileName: String {
        return self.rawValue.firstUpperCased!
    }
}

extension UIStoryboard {
    convenience init(storyboard: Storyboard, bundle: Bundle?) {
        self.init(name: storyboard.fileName, bundle: bundle)
    }
    
    func instantiateViewController<T: UIViewController>(_ viewControllerType: T.Type) -> T {
        return instantiateViewController(withIdentifier: String(describing: viewControllerType)) as! T
    }
}


