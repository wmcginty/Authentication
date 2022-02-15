//
//  AuthenticationController.swift
//  App
//
//  Created by William McGinty on 4/30/18.
//

import Vapor
import Fluent

struct AuthenticationController {
    
    //MARK: Actions
    func authenticationContainer(for refreshToken: String, on database: Database) async throws -> AuthenticationContainer {
        let user = try await existingUser(matchingTokenString: refreshToken, on: database)
        return try await authenticationContainer(for: user, on: database)
    }
    
    func authenticationContainer(for user: User, on database: Database) async throws -> AuthenticationContainer {
        try await removeAllTokens(for: user, on: database)
        return AuthenticationContainer(accessToken: try await accessToken(for: user, on: database),
                                       refreshToken: try await refreshToken(for: user, on: database))
    }
    
    func revokeTokens(forEmail email: String, on database: Database) async throws {
        guard let user = try await User.query(on: database).filter(\.$email == email).first() else { return }
        return try await removeAllTokens(for: user, on: database)
    }
}

//MARK: Helper
private extension AuthenticationController {
    
    //MARK: Queries
    func existingUser(matchingTokenString tokenString: String, on database: Database) async throws -> User {
        guard let token = try await RefreshToken.query(on: database).filter(\.$tokenString == tokenString).first() else {
            throw Abort(.notFound)
        }
        
        return try await token.$user.get(on: database)
    }
    
    func existingUser(matching user: User, on database: Database) async throws -> User? {
        return try await User.query(on: database).filter(\.$email == user.email).first()
    }
    
    //MARK: Cleanup
    func removeAllTokens(for user: User, on database: Database) async throws {
        guard let userID = user.id else { return }
        try await AccessToken.query(on: database).filter(\.$user.$id == userID).delete()
        try await RefreshToken.query(on: database).filter(\.$user.$id == userID).delete()
    }
    
    //MARK: Generation
    func accessToken(for user: User, on database: Database) async throws -> AccessToken {
        let token = try AccessToken(user: user)
        try await token.save(on: database)
        
        return token
    }
    
    func refreshToken(for user: User, on database: Database) async throws -> RefreshToken {
        let token = try RefreshToken(user: user)
        try await token.save(on: database)
        
        return token
    }
    
    func accessToken(for refreshToken: RefreshToken, on database: Database) async throws -> AccessToken {
        let token = try AccessToken(user: refreshToken.user)
        try await token.save(on: database)
        
        return token
    }
}
