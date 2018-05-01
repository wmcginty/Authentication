//
//  User.swift
//  App
//
//  Created by William McGinty on 3/21/18.
//

import Foundation
import Vapor
import Fluent
import FluentSQLite
import Authentication

struct User: Content, SQLiteUUIDModel, Migration {
    
    //MARK: Properties
    var id: UUID?
    private(set) var email: String
    private(set) var password: String
}

//MARK: BasicAuthenticatable
extension User: BasicAuthenticatable {
    
    static let usernameKey: WritableKeyPath<User, String> = \.email
    static let passwordKey: WritableKeyPath<User, String> = \.password
}

//MARK: TokenAuthenticatable
extension User: TokenAuthenticatable {
    typealias TokenType = AccessToken
}
