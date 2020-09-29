//
//  AccessToken.swift
//  App
//
//  Created by William McGinty on 3/22/18.
//

import Vapor
import Fluent
import FluentSQLiteDriver
import Crypto

final class AccessToken: Content, Model {
    static let schema: String = "access_tokens"

    //MARK: Constants
    static let accessTokenExpirationInterval: TimeInterval = 3600 * 6
    
    //MARK: Properties
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "token_string")
    var tokenString: String
    
    @Parent(key: "user_id")
    var user: User
    
    @Field(key: "expiry")
    var expiryDate: Date
    
    //MARK: Initializers
    init() { /* No op */ }
 
    init(user: User) throws {
        self.tokenString = Data([UInt8].random(count: 32)).base64EncodedString()
        self.expiryDate = Date().addingTimeInterval(AccessToken.accessTokenExpirationInterval)
        self.$user.id = try user.requireID()
    }
}

// MARK: Migration
extension AccessToken {
    
    struct Migration: Fluent.Migration {
        let name: String = AccessToken.schema
        
        func prepare(on database: Database) -> EventLoopFuture<Void> {
            return database.schema(AccessToken.schema)
                .id()
                .field("token_string", .string, .required)
                .field("user_id", .uuid, .required, .references("users", "id"))
                .field("expiry", .datetime, .required)
                .create()
        }
        
        func revert(on database: Database) -> EventLoopFuture<Void> {
            return database.schema(AccessToken.schema).delete()
        }
    }
}

// MARK: ModelTokenAuthenticatable
extension AccessToken: ModelTokenAuthenticatable {
    
    static var userKey: KeyPath<AccessToken, Parent<User>> = \.$user
    static var valueKey: KeyPath<AccessToken, Field<String>> = \.$tokenString
    
    var isValid: Bool { return expiryDate > Date() }
}
