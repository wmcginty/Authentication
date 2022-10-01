//
//  SocialUser.swift
//  
//
//  Created by Will McGinty on 9/30/22.
//

import Vapor
import JWTKit

enum SocialUser {
    
    // MARK: - Registratn
    public struct Registrant: Content, Equatable {
        
        // MARK: - Properties
        let identityToken: Data?
        let authorizationCode: Data?
        let nonce: String?
    }
    
    struct VerificationPayload: JWTPayload, Equatable {
        
        // MARK: - Properties
        var subject: SubjectClaim
        var issuer: IssuerClaim
        var audience: AudienceClaim
        var expiration: ExpirationClaim

        // Custom data.
        var isNonceSupported: Bool
        var nonce: String
        var email: String

        // MARK: - JWTPayload
        func verify(using signer: JWTSigner) throws {
            try audience.verifyIntendedAudience(includes: "com.mcginty.will.Auth")
            guard issuer.value.contains("https://appleid.apple.com") else {
                throw JWTError.claimVerificationFailure(name: "iss", reason: "invalid issuer")
            }
            
            try self.expiration.verifyNotExpired()
        }
        
        // MARK: - Codable
        enum CodingKeys: String, CodingKey {
            case subject = "sub"
            case issuer = "iss"
            case audience = "aud"
            case expiration = "exp"
            case isNonceSupported = "nonce_supported"
            case nonce, email
        }
    }
}

