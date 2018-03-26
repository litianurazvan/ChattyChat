//
//  String+CapitalisedFirst.swift
//  FirebaseLogin
//
//  Created by Razvan Litianu on 09/03/2018.
//  Copyright © 2018 Razvan Litianu. All rights reserved.
//

import Foundation

extension String {
    var firstUpperCased: String? {
        guard let firstCharacter = self.first else { return nil }
        let firstLetter = String(describing: firstCharacter).capitalized
        return firstLetter + String(dropFirst())
    }
}
