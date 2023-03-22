//
//  User.swift
//  App
//
//  Created by William McGinty on 3/21/18.
//

import Vapor
import Fluent

final class User: Content, Model, Authenticatable {
    static let schema: String = "users"
    
    //MARK: Properties
    @ID(key: .id)
    var id: UUID?
    
    @OptionalField(key: "social_id")
    private(set) var socialID: String?
    
    @Field(key: "email")
    private(set) var email: String
    
    @Field(key: "password")
    private(set) var password: String
    
    // MARK: Initializers
    init() { /* No op */ }
    
    init(id: UUID? = nil, socialID: String? = nil, email: String, password: String) {
        self.id = id
        self.socialID = socialID
        self.email = email
        self.password = password
    }
    
    // MARK: Interface
    func hashingPassword() throws -> User {
        return User(id: id, socialID: socialID, email: email, password: try BCryptDigest().hash(password))
    }
    
    static func social(verifiedRegistrant payload: SocialUser.VerificationPayload) throws -> User {
        return try User(socialID: payload.subject.value, email: payload.email,
                        password: Data([UInt8].random(count: 32)).base64EncodedString()).hashingPassword()
    }
}

// MARK: Migration
extension User {
    
    struct Migration: Fluent.AsyncMigration {
        let name = User.schema
        
        func prepare(on database: Database) async throws {
            return try await database.schema(User.schema)
                .id()
                .field("email", .string, .required)
                .unique(on: "email")
                .field("password", .string, .required)
                .field("social_id", .string)
                .create()
        }
        
        func revert(on database: Database) async throws {
            return try await database.schema(User.schema).delete()
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

// MARK: Registration / Authentication Helpers
extension User {
    
    static func uniqueUsername(forFirstName first: String, lastName last: String) -> String {
        return "\(first).\(last)-\(Date().timeIntervalSince1970)".lowercased()
    }
    
    static func uniqueness(forEmail email: String, on request: Request) async throws -> Bool {
        return try await !User.isExisting(matching: \.$email == email, on: request.db)
    }
    
    static func ensureUniqueness(for registrant: User, on request: Request) async throws {
        let unique = try await User.uniqueness(forEmail: registrant.email, on: request)
        guard unique else { throw Abort(.badRequest, reason: "A user with this email or username already exists") }
    }
}
