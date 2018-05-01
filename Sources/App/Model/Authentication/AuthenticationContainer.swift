//
//  AuthenticationContainer.swift
//  App
//
//  Created by William McGinty on 3/22/18.
//

import Foundation
import Vapor

public struct AuthenticationContainer: Content {
    
    //MARK: Properties
    public let accessToken: AccessToken.Token
    public let expiresIn: TimeInterval
    public let refreshToken: RefreshToken.Token
    
    //MARK: Initializers
    public init(accessToken: AccessToken, refreshToken: RefreshToken) {
        self.accessToken = accessToken.tokenString
        self.expiresIn = AccessToken.accessTokenExpirationInterval
        self.refreshToken = refreshToken.tokenString
    }
}

public struct RefreshTokenContainer: Content {
    
    //MARK: Properties
    public let refreshToken: RefreshToken.Token
}
