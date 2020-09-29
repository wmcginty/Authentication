//
//  AuthenticationController.swift
//  App
//
//  Created by William McGinty on 4/30/18.
//

import Foundation
import Vapor
import Fluent
import FluentSQLiteDriver
import Crypto

struct AuthenticationController {
    
    //MARK: Actions
    func authenticationContainer(for refreshToken: String, on database: Database) throws -> EventLoopFuture<AuthenticationContainer> {
        return try existingUser(matchingTokenString: refreshToken, on: database).throwingFlatMap { user in
            return try self.authenticationContainer(for: user, on: database)
        }
    }
    
    func authenticationContainer(for user: User, on database: Database) throws -> EventLoopFuture<AuthenticationContainer> {
        return try removeAllTokens(for: user, on: database).throwingFlatMap { _ in
            return try self.accessToken(for: user, on: database).and(self.refreshToken(for: user, on: database)).map { access, refresh in
                return AuthenticationContainer(accessToken: access, refreshToken: refresh)
            }
        }
    }
    
    func revokeTokens(forEmail email: String, on database: Database) throws -> EventLoopFuture<Void> {
        return User.query(on: database).filter(\.$email == email).first().throwingFlatMap { user in
            guard let user = user else { return database.eventLoop.future() }
            return try self.removeAllTokens(for: user, on: database)
        }
    }
}

//MARK: Helper
private extension AuthenticationController {
    
    //MARK: Queries
    func existingUser(matchingTokenString tokenString: String, on database: Database) throws -> EventLoopFuture<User> {
        return RefreshToken.query(on: database).filter(\.$tokenString == tokenString).first().throwingFlatMap { token in
            guard let token = token else { throw Abort(.notFound /* token not found */) }
            return token.$user.get(on: database)
        }
    }
    
    func existingUser(matching user: User, on database: Database) throws -> EventLoopFuture<User?> {
        return User.query(on: database).filter(\.$email == user.email).first()
    }
    
    //MARK: Cleanup
    func removeAllTokens(for user: User, on database: Database) throws -> EventLoopFuture<Void> {
        guard let userID = user.id else { return database.eventLoop.future() }
        let accessTokens = AccessToken.query(on: database).filter(\.$user.$id == userID).delete()
        let refreshToken = RefreshToken.query(on: database).filter(\.$user.$id == userID).delete()
        
        return accessTokens.and(refreshToken).map { _, _ in Void() }
    }
    
    //MARK: Generation
    func accessToken(for user: User, on database: Database) throws -> EventLoopFuture<AccessToken> {
        return try AccessToken(user: user).saveAndReturn(on: database)
    }
    
    func refreshToken(for user: User, on database: Database) throws -> EventLoopFuture<RefreshToken> {
        return try RefreshToken(user: user).saveAndReturn(on: database)
    }
    
    func accessToken(for refreshToken: RefreshToken, on database: Database) throws -> EventLoopFuture<AccessToken> {
        return try AccessToken(user: refreshToken.user).saveAndReturn(on: database)
    }
}
