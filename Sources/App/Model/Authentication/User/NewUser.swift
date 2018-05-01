//
//  NewUser.swift
//  App
//
//  Created by William McGinty on 3/21/18.
//

import Foundation
import Vapor
import Validation
import Authentication

struct NewUser: Content {
    
    //MARK: Properties
    private var id: UUID?
    let email: String
    let password: String
    let passwordConfirmation: String
    
    //MARK: Codable
    private enum CodingKeys: String, CodingKey {
        case email, password
        case passwordConfirmation = "password_confirmation"
    }
}

extension NewUser: Validatable {
    
    static func validations() throws -> Validations<NewUser> {
        var validations = Validations(NewUser.self)
        validations.add(\.email, at: [], .email)
        validations.add(\.password, at: [], .password)
        
        let newUserConfirmationValidator = Validator<NewUser>.passwordConfirmation
        validations.add(newUserConfirmationValidator.readable, newUserConfirmationValidator.validate)
        
        return validations
    }
    
    
}
