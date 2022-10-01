//
//  AuthenticationController.swift
//  App
//
//  Created by William McGinty on 3/25/18.
//

import Vapor

struct AuthenticationRouteController: RouteCollection {
    
    private let authController = AuthenticationController()
    
    func boot(routes: RoutesBuilder) throws {
        let group = routes.grouped("api", "token")
        group.post(RefreshTokenContainer.self, path: "refresh", use: refreshAccessTokenHandler)
        
        let basicAuthGroup = group.grouped([User.authenticator(), User.guardMiddleware()])
        basicAuthGroup.post(UserEmailContainer.self, path: "revoke", use: accessTokenRevocationhandler)
    }
}

//MARK: Helper
private extension AuthenticationRouteController {
    
    func refreshAccessTokenHandler(_ request: Request, container: RefreshTokenContainer) async throws -> AuthenticationContainer {
        return try await authController.authenticationContainer(for: container.refreshToken, on: request.db)
    }
    
    func accessTokenRevocationhandler(_ request: Request, container: UserEmailContainer) async throws -> HTTPStatus {
        try await authController.revokeTokens(forEmail: container.email, on: request.db)
        return .ok
    }
}

