//
//  UserRouteController.swift
//  App
//
//  Created by William McGinty on 4/30/18.
//

import Vapor
import Fluent
import FluentSQLite
import Crypto
import Logging

class UserRouteController: RouteCollection {
    
    private let authController = AuthenticationController()
    
    func boot(router: Router) throws {
        let group = router.grouped("api", "users")
        group.post(User.self, at: "login", use: loginUserHandler)
        group.post(NewUser.self, at: "register", use: registerUserHandler)
    }
}

//MARK: Helper
private extension UserRouteController {
    
    func loginUserHandler(_ request: Request, user: User) throws -> Future<AuthenticationContainer> {
        return try User.query(on: request).filter(\.email == user.email).first().flatMap { existingUser in
            guard let existingUser = existingUser else { throw Abort(.badRequest, reason: "this user does not exist" , identifier: nil) }
            
            let digest = try request.make(BCryptDigest.self)
            guard try digest.verify(user.password, created: existingUser.password) else { throw Abort(.badRequest) /* authentication failure */ }
            
            return try self.authController.authenticationContainer(for: existingUser, on: request)
        }
    }
    
    func registerUserHandler(_ request: Request, newUser: NewUser) throws -> Future<AuthenticationContainer> {
        return try User.query(on: request).filter(\.email == newUser.email).first().flatMap { existingUser in
            guard existingUser == nil else { throw Abort(.badRequest, reason: "a user with this email already exists" , identifier: nil) }
            
            try newUser.validate()
            
            return try newUser.user(with: request.make(BCryptDigest.self)).save(on: request).flatMap { user in
                
                let logger = try request.make(Logger.self)
                logger.warning("New user created: \(user.email)")
                
                return try self.authController.authenticationContainer(for: user, on: request)
            }
        }
    }
}

//MARK: NewUser+User
private extension NewUser {
        
    func user(with digest: BCryptDigest) throws -> User {
        return try User(id: nil, email: email, password: digest.hash(password))
    }
}
