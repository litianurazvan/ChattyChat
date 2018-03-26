//
//  CoordinatorDelegate.swift
//  ChattyChat
//
//  Created by Razvan Litianu on 16/03/2018.
//  Copyright © 2018 Razvan Litianu. All rights reserved.
//

import Foundation

protocol RegistrationCoordinatorDelegate: AnyObject {
    func registrationDidFinishCoordinating(_ coordinator: CoordinatorType)
}
