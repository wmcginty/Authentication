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
    
    private let authController = AuthenticationController()
    
    func boot(router: Router) throws {
        let group = router.grouped("api", "token")
        group.post(RefreshTokenContainer.self, at: "refresh", use: refreshAccessTokenHandler)
    }
}

//MARK: Helper
private extension AuthenticationRouteController {
    
    func refreshAccessTokenHandler(_ request: Request, container: RefreshTokenContainer) throws -> Future<AuthenticationContainer> {
        return try authController.authenticationContainer(for: container.refreshToken, on: request)
    }
}

