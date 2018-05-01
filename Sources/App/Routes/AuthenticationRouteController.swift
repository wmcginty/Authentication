//
//  AuthenticationController.swift
//  App
//
//  Created by William McGinty on 3/25/18.
//

import Foundation
import Vapor
import Fluent
import FluentSQLite
import Crypto

struct AuthenticationRouteController: RouteCollection {
    
    func boot(router: Router) throws {
        //
    }
    
    
}

//struct AuthenticationController: RouteCollection {
//    
//    //MARK: Authentication
//    func authenticate(_ user: User, with hasher: BCryptDigest, on connection: DatabaseConnectable) throws -> Future<AuthenticationContainer> {
//        return try existingUser(withEmail: user.email, on: connection).flatMap(to: AuthenticationContainer.self) { existingUser in
//            guard let existingUser = existingUser, let userID = existingUser.id else { throw Abort(.notFound) }
//            guard try hasher.verify(user.password, created: existingUser.password) else {
//                throw Abort(HTTPResponseStatus.custom(code: 401, reasonPhrase: "The username or password was incorrect."))
//            }
//
//            //The user is valid - create a new auth/refresh token and issue them
//            return try self.authenticationContainer(forUserID: userID, on: connection)
//        }
//    }
//    
//    func authenticationContainer(forUserID userID: UUID, on connection: DatabaseConnectable) throws -> Future<AuthenticationContainer> {
//        return try removeAllTokens(matchingUserID: userID, on: connection).flatMap(to: AuthenticationContainer.self) { void in
//            return map(to: AuthenticationContainer.self, self.accessToken(for: userID, on: connection), self.refreshToken(for: userID, on: connection)) { a, r in
//                return AuthenticationContainer(accessToken: a, refreshToken: r)
//            }
//        }
//    }
//    
//    //MARK: Token Validation
//    func tokenValidation(for accessToken: AccessToken.Token, on connection: DatabaseConnectable) throws -> Future<Bool> {
//        return try AccessToken.query(on: connection).filter(\.tokenString == accessToken).first().map(to: Bool.self) { existingToken in
//            guard let existingToken = existingToken else { throw Abort(.unauthorized) }
//            let isValid = Date() < existingToken.expiryTime
//            
//            if !isValid {
//                _ = existingToken.delete(on: connection)
//            }
//            
//            return isValid
//        }
//    }
//    
//    func refreshToken(withString tokenString: RefreshToken.Token, on connection: DatabaseConnectable) throws -> Future<RefreshToken?> {
//        return try RefreshToken.query(on: connection).filter(\.tokenString == tokenString).first()
//    }
//}
//

