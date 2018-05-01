//
//  ProtectedRoutesController.swift
//  App
//
//  Created by William McGinty on 4/30/18.
//

import Foundation
import Vapor
import Authentication
import Crypto

struct ProtectedRoutesController: RouteCollection {
    
    func boot(router: Router) throws {
        let group = router.grouped("api", "protected")
        
        let basicAuthMiddleware = User.basicAuthMiddleware(using: BCrypt)
        let basicAuthGroup = group.grouped(basicAuthMiddleware)
        basicAuthGroup.get("basic", use: basicAuthRouteHandler)
        
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let tokenAuthGroup = group.grouped(tokenAuthMiddleware)
        tokenAuthGroup.get("token", use: tokenAuthRouteHandler)
    }
}

//MARK: Helper
private extension ProtectedRoutesController {
    
    func basicAuthRouteHandler(_ request: Request) throws -> HTTPResponseStatus {
        return .ok
    }
    
    func tokenAuthRouteHandler(_ request: Request) throws -> HTTPResponseStatus {
        return .ok
    }
}
