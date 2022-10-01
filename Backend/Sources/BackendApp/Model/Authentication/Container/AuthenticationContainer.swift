//
//  AuthenticationContainer.swift
//  App
//
//  Created by William McGinty on 3/22/18.
//

import Vapor

struct AuthenticationContainer: Content {
    
    //MARK: Properties
    let accessToken: String
    let expiresIn: TimeInterval
    let refreshToken: String
    
    //MARK: Initializers
    init(accessToken: AccessToken, refreshToken: RefreshToken) {
        self.accessToken = accessToken.tokenString
        self.expiresIn = AccessToken.accessTokenExpirationInterval //Not honored, just an estimate
        self.refreshToken = refreshToken.tokenString
    }
    
    //MARK: Codable
    private enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case expiresIn = "expires_in"
        case refreshToken = "refresh_token"
    }
}

struct RefreshTokenContainer: Content {
    
    //MARK: Properties
    let refreshToken: String
    
    private enum CodingKeys: String, CodingKey {
        case refreshToken = "refresh_token"
    }
}
