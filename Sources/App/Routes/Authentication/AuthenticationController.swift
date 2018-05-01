//
//  AuthenticationController.swift
//  App
//
//  Created by William McGinty on 4/30/18.
//

import Foundation
import Vapor
import Fluent
import FluentSQLite
import Crypto



struct AuthenticationController {
    
    //MARK: Actions
    func authenticationContainer(for refreshToken: RefreshToken.Token, on connection: DatabaseConnectable) throws -> Future<AuthenticationContainer> {
        return try existingUser(matchingTokenString: refreshToken, on: connection).flatMap { user in
            guard let user = user else { throw Abort(.notFound) }
            return try self.authenticationContainer(for: user, on: connection)
        }
    }
    
    func authenticationContainer(for user: User, on connection: DatabaseConnectable) throws -> Future<AuthenticationContainer> {
        return try removeAllTokens(for: user, on: connection).flatMap { _ in
            return try map(to: AuthenticationContainer.self, self.accessToken(for: user, on: connection), self.refreshToken(for: user, on: connection)) { access, refresh in
                return AuthenticationContainer(accessToken: access, refreshToken: refresh)
            }
        }
    }
}

//MARK: Helper
private extension AuthenticationController {
    
    //MARK: Queries
    func existingUser(matchingTokenString tokenString: RefreshToken.Token, on connection: DatabaseConnectable) throws -> Future<User?> {
        return try RefreshToken.query(on: connection).filter(\.tokenString == tokenString).first().flatMap { token in
            guard let token = token else { throw Abort(.notFound /* token not found */) }
            return try User.query(on: connection).filter(\.id == token.userID).first()
        }
    }
    
    func existingUser(matching user: NewUser, on connection: DatabaseConnectable) throws -> Future<User?> {
        return try User.query(on: connection).filter(\.email == user.email).first()
    }
    
    //MARK: Cleanup
    func removeAllTokens(for user: User, on connection: DatabaseConnectable) throws -> Future<Void> {
        let accessTokens = try AccessToken.query(on: connection).filter(\.userID == user.id).delete()
        let refreshToken = try RefreshToken.query(on: connection).filter(\.userID == user.id).delete()
        
        return map(to: Void.self, accessTokens, refreshToken) { _, _ in Void() }
    }
    
    //MARK: Generation
    func accessToken(for user: User, on connection: DatabaseConnectable) throws -> Future<AccessToken> {
        return try AccessToken(userID: user.requireID()).save(on: connection)
    }
    
    func refreshToken(for user: User, on connection: DatabaseConnectable) throws -> Future<RefreshToken> {
        return try RefreshToken(userID: user.requireID()).save(on: connection)
    }
    
    func accessToken(for refreshToken: RefreshToken, on connection: DatabaseConnectable) throws -> Future<AccessToken> {
        return try AccessToken(userID: refreshToken.userID).save(on: connection)
    }
}
