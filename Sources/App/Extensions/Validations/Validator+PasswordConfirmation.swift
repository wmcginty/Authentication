//
//  Validator+PasswordConfirmation.swift
//  App
//
//  Created by William McGinty on 4/30/18.
//

import Foundation
import Validation

fileprivate struct PasswordConfirmationValidator: ValidatorType {
    
    //MARK: Properties
    public var validatorReadable: String { return "a valid new user in which the password and confirmation match" }
    
    //MARK: Initializers
    public init() { }
    
    public func validate(_ s: NewUser) throws {
        guard s.password == s.passwordConfirmation else { throw BasicValidationError("password and password_confirmation do not match.") }
    }
}

extension Validator where T == NewUser {
    
    /// Validates that a 'NewUser' has correctly confirmed their password
    static var passwordConfirmation: Validator<T> {
        return PasswordConfirmationValidator().validator()
    }
}
