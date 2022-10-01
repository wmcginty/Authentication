//
//  ProtectedRoutesController.swift
//  App
//
//  Created by William McGinty on 4/30/18.
//

import Vapor

struct ProtectedRoutesController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        let group = routes.grouped("api", "protected")
        
        let basicAuthGroup = group.grouped([User.authenticator(), User.guardMiddleware()])
        basicAuthGroup.get("basic", use: basicAuthRouteHandler)
        
        let tokenAuthGroup = group.grouped([AccessToken.authenticator(), AccessToken.guardMiddleware()])
        tokenAuthGroup.get("token", use: tokenAuthRouteHandler)
    }
}

//MARK: Helper
private extension ProtectedRoutesController {
    
    func basicAuthRouteHandler(_ request: Request) throws -> User {
        return try request.auth.require()
    }
    
    func tokenAuthRouteHandler(_ request: Request) throws -> User {
        return try request.auth.require()
    }
}
