//
//  User.swift
//  App
//
//  Created by William McGinty on 3/21/18.
//

import Foundation
import Vapor
import Fluent
import FluentSQLiteDriver

final class User: Content, Model, Authenticatable {
    static let schema: String = "users"
    
    //MARK: Properties
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "email")
    private(set) var email: String
    
    @Field(key: "password")
    private(set) var password: String
    
    // MARK: Initializers
    init() { /* No op */ }
    
    init(id: UUID? = nil, email: String, password: String) {
        self.id = id
        self.email = email
        self.password = password
    }
    
    // MARK: Interface
    func hashingPassword() throws -> User {
        return User(id: id, email: email, password: try BCryptDigest().hash(password))
    }
}

// MARK: Migration
extension User {
    
    struct Migration: Fluent.Migration {
        let name = User.schema
        
        func prepare(on database: Database) -> EventLoopFuture<Void> {
            return database.schema(User.schema)
                .id()
                .field("email", .string, .required)
                .unique(on: "email")
                .field("password", .string, .required)
                .create()
        }
        
        func revert(on database: Database) -> EventLoopFuture<Void> {
            return database.schema(User.schema).delete()
        }
    }
}

//MARK: Authenticatable
extension User: ModelAuthenticatable {
    
    static var usernameKey: KeyPath<User, Field<String>> = \.$email
    static var passwordHashKey: KeyPath<User, Field<String>> = \.$password
    
    func verify(password: String) throws -> Bool {
        return try Bcrypt.verify(password, created: self.password)
    }
}
//
////MARK: Validatable
//extension User: Validatable {
//
//    static func validations(_ validations: inout Validations) {
//       // var validations = Validations(User.self)
//        validations.
//        validations.add(\.email, at: [], .email)
//        validations.add(\.password, at: [], .password)
//    }
//
//    static func validations() throws -> Validations<User> {
//        var validations = Validations(User.self)
//        validations.add(\.email, at: [], .email)
//        validations.add(\.password, at: [], .password)
//
//        return validations
//    }
//}

// MARK: Registration / Authentication Helpers
extension User {
    
    static func uniqueUsername(forFirstName first: String, lastName last: String) -> String {
        return "\(first).\(last)-\(Date().timeIntervalSince1970)".lowercased()
    }
    
    static func uniqueness(forEmail email: String, on request: Request) -> EventLoopFuture<Bool> {
        return User.isExisting(matching: \.$email == email, on: request.db)
    }
    
    static func ensureUniqueness(for registrant: User, on request: Request) -> EventLoopFuture<Void> {
         return User.uniqueness(forEmail: registrant.email, on: request).flatMapThrowing {
             guard $0 else { throw Abort(.badRequest, reason: "A user with this email or username already exists") }
         }
     }
}
