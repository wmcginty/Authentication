//
//  SocialUserRouteController.swift
//  
//
//  Created by Will McGinty on 9/30/22.
//

import Fluent
import JWTKit
import Vapor

class SocialUserRouteController: RouteCollection {
    
    private let authController = AuthenticationController()
    
    func boot(routes: RoutesBuilder) throws {
        let group = routes.grouped("api", "users")
        
        group.post(SocialUser.Registrant.self, path: "login", "apple", use: signInWithAppleHandler)
    }
}

//MARK: Request Handlers
private extension SocialUserRouteController {
    
    func signInWithAppleHandler(_ request: Request, registrant: SocialUser.Registrant) async throws -> AuthenticationContainer {
        let keys = try await retrieveAppleAuthKeys(on: request)
        let verifiedPayload = try await verify(registrant: registrant, using: keys)
        
        if let existing = try await User.existing(matching: \.$socialID == verifiedPayload.subject.value, on: request.db) {
            return try await authController.authenticationContainer(for: existing, on: request.db)
        } else {
            let socialUser = try User.social(verifiedRegistrant: verifiedPayload)
            try await socialUser.save(on: request.db)
            
            return try await authController.authenticationContainer(for: socialUser, on: request.db)
        }
    }
}

// MARK: - Verification Helper
private extension SocialUserRouteController {
    
    func verify(registrant: SocialUser.Registrant, using keys: JWKS) async throws -> SocialUser.VerificationPayload {
        let signers = JWTSigners()
        try signers.use(jwks: keys)
        
        let verifiedPayload = try signers.verify(registrant.identityToken ?? Data(),as: SocialUser.VerificationPayload.self)
        
        if verifiedPayload.isNonceSupported {
            guard verifiedPayload.nonce == registrant.nonce else {
                throw JWTError.claimVerificationFailure(name: "nonce", reason: "invalid nonce")
            }
        }
        
        return verifiedPayload
    }
    
    func retrieveAppleAuthKeys(on request: Request) async throws -> JWKS {
        let uri = URI("https://appleid.apple.com/auth/keys")
        let jwksResponse = try await request.client.get(uri)
        return try jwksResponse.content.decode(JWKS.self)
    }
}
