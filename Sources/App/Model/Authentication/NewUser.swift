//
//  NewUser.swift
//  App
//
//  Created by William McGinty on 3/21/18.
//

import Foundation
import Vapor

struct NewUser: Content {
    
    //MARK: Properties
    let email: String
    let password: String
    let passwordConfirmation: String
}
