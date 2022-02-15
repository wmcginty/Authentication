//
//  UserRouteController.swift
//  App
//
//  Created by William McGinty on 4/30/18.
//

import Vapor

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
    
    func loginUserHandler(_ request: Request) async throws -> AuthenticationContainer {
        return try await authController.authenticationContainer(for: request.auth.require(), on: request.db)
    }
    
    func registerUserHandler(_ request: Request, registrant: User) async throws -> AuthenticationContainer {
        try await User.ensureUniqueness(for: registrant, on: request)
        
        let user = try registrant.hashingPassword()
        try await user.save(on: request.db)
        return try await authController.authenticationContainer(for: user, on: request.db)
    }
}
