//
//  NewUser.swift
//  App
//
//  Created by William McGinty on 3/21/18.
//

import Foundation
import Vapor
import Authentication
import Crypto

struct NewUser: Content {
    
    //MARK: Properties
    let email: String
    let password: String
    let passwordConfirmation: String
    
    //MARK: Codable
    private enum CodingKeys: String, CodingKey {
        case email, password
        case passwordConfirmation = "password_confirmation"
    }
    
    func user(with digest: BCryptDigest) throws -> User {
        return try User(id: nil, email: email, password: digest.hash(password))
    }
}
