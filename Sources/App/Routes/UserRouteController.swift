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

class UserRouteController: RouteCollection {
    
    func boot(router: Router) throws {
        let group = router.grouped("api", "users")
        group.post(NewUser.self, at: "register", use: registerUserHandler)
    }
}

//MARK: Helper
private extension UserRouteController {
    
    func registerUserHandler(_ request: Request, newUser: NewUser) throws -> Future<HTTPResponseStatus> {
        return try User.query(on: request).filter(\.email == newUser.email).first().flatMap { existingUser in
            guard existingUser == nil else { throw Abort(.badRequest, reason: "a user with this email already exists" , identifier: nil) }
            
            try newUser.validate()
            return try newUser.user(with: request.make(BCryptDigest.self)).save(on: request).transform(to: .created)
        }
    }
}
