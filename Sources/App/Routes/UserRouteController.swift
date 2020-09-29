//
//  UserRouteController.swift
//  App
//
//  Created by William McGinty on 4/30/18.
//

import Vapor
import Crypto
import Logging

class UserRouteController: RouteCollection {
    
    private let authController = AuthenticationController()
    
    func boot(routes: RoutesBuilder) throws {
        let group = routes.grouped("api", "users")
        
        let basicAuthenticated = group.grouped([User.authenticator(), User.guardMiddleware()])
        basicAuthenticated.get("login", use: loginUserHandler)
        
        group.post(User.self, path: "register", use: registerUserHandler)
    }
}

//MARK: Helper
private extension UserRouteController {
    
    func loginUserHandler(_ request: Request) throws -> EventLoopFuture<AuthenticationContainer> {
        return try authController.authenticationContainer(for: request.auth.require(), on: request.db)
    }
    
    func registerUserHandler(_ request: Request, registrant: User) throws -> EventLoopFuture<AuthenticationContainer> {
        return User.ensureUniqueness(for: registrant, on: request).throwingFlatMap {
            return try registrant.hashingPassword().saveAndReturn(on: request.db).throwingFlatMap { user in
                return try self.authController.authenticationContainer(for: user, on: request.db)
            }
        }
    }
}
