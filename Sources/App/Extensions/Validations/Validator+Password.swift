//
//  Validator+Password.swift
//  App
//
//  Created by William McGinty on 4/30/18.
//

import Foundation
import Validation

fileprivate struct PasswordValidator: ValidatorType {
    
    //MARK: Properties
    private var asciiValidator: Validator = .ascii
    private var lengthValidator: Validator<String> = Validator.count(8...)
    private var numberValidator: Validator<String> = Validator.containsCharacterFrom(set: .decimalDigits)
    private var lowercaseValidator: Validator<String> = Validator.containsCharacterFrom(set: .lowercaseLetters)
    private var uppercaseValidator: Validator<String> = Validator.containsCharacterFrom(set: .uppercaseLetters)
    
    public var validatorReadable: String { return "a valid password of 8 or more ASCII characters" }
    
    //MARK: Initializers
    public init() {}
    
    public func validate(_ s: String) throws {
        try asciiValidator.validate(s)
        try lengthValidator.validate(s)
        try numberValidator.validate(s)
        try lowercaseValidator.validate(s)
        try uppercaseValidator.validate(s)  
    }
}

fileprivate struct ContainsCharacterFromSetValidator: ValidatorType {
    
    //MARK: Properties
    private let characterSet: CharacterSet
    
    public var validatorReadable: String { return "a valid string consisting of at least one character from a given set" }
    
    //MARK: Initializers
    public init(characterSet: CharacterSet) {
        self.characterSet = characterSet
    }
    
    public func validate(_ s: String) throws {
        guard let _ = s.rangeOfCharacter(from: characterSet) else { throw BasicValidationError("does not contain a member of character set: \(characterSet.description)") }
    }
}

extension Validator where T == String {
    
    /// Validates that a 'String' is a functioning password - 8+ ascii characters, 1 uppercase, 1 lowercase, 1 number
    public static var password: Validator<T> {
        return PasswordValidator().validator()
    }
    
    /// Validates that a single character in a `String` are in the supplied `CharacterSet`.
    public static func containsCharacterFrom(set: CharacterSet) -> Validator<T> {
        return ContainsCharacterFromSetValidator(characterSet: set).validator()
    }
}
