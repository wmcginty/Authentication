//
//  RefreshToken.swift
//  App
//
//  Created by William McGinty on 3/22/18.
//

import Foundation
import Vapor
import Fluent
import FluentSQLiteDriver
import Crypto

final class RefreshToken: Content, Model {
    static var schema: String = "refresh_tokens"
    
    //MARK: Properties
    @ID(key: .id)
    var id: UUID?
    
    // TODO: Hash this with BCrypt before storage, and then verify when a token is received to initiate a refresh
    @Field(key: "token_string")
    var tokenString: String
    
    @Parent(key: "user_id")
    var user: User
    
    //MARK: Initializers
    init() { /* No op */ }
    
    init(user: User) throws {
        self.tokenString = Data([UInt8].random(count: 32)).base64EncodedString()
        self.$user.id = try user.requireID()
    }
}

// MARK: Migration
extension RefreshToken {
    
    struct Migration: Fluent.Migration {
        let name = RefreshToken.schema
        
        func prepare(on database: Database) -> EventLoopFuture<Void> {
            return database.schema(RefreshToken.schema)
                .id()
                .field("token_string", .string, .required)
                .field("user_id", .uuid, .required, .references("users", "id"))
                .create()
        }
        
        func revert(on database: Database) -> EventLoopFuture<Void> {
            return database.schema(RefreshToken.schema).delete()
        }
    }
}
