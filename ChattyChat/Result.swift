//
//  Result.swift
//  ChattyChat
//
//  Created by Razvan Litianu on 25/04/2018.
//  Copyright © 2018 Razvan Litianu. All rights reserved.
//

import Foundation

enum Result<T> {
    case success(result: T)
    case failure(error: Error)
}
