//
//  AccessToken.swift
//  App
//
//  Created by William McGinty on 3/22/18.
//

import Foundation
import Vapor
import Fluent
import FluentSQLite
import Crypto
import Authentication

struct AccessToken: Content, SQLiteUUIDModel, Migration {
    typealias Token = String
    
    //MARK: Constants
    static let accessTokenExpirationInterval: TimeInterval = 3600
    
    //MARK: Properties
    var id: UUID?
    private(set) var tokenString: Token
    private(set) var userID: UUID
    let expiryTime: Date
    
    //MARK: Initializers
    init(userID: UUID) throws {
        self.tokenString = try CryptoRandom().generateData(count: 32).base64URLEncodedString()
        self.userID = userID
        self.expiryTime = Date().addingTimeInterval(AccessToken.accessTokenExpirationInterval)
    }
}

//MARK: BearerAuthenticatable
extension AccessToken: BearerAuthenticatable {
    
    static let tokenKey: WritableKeyPath<AccessToken, String> = \.tokenString
    
    public static func authenticate(using bearer: BearerAuthorization, on connection: DatabaseConnectable) -> Future<AccessToken?> {
        return Future.flatMap(on: connection) {
            return try AccessToken.query(on: connection).filter(tokenKey == bearer.token).first().map { token in
                guard let token = token, token.expiryTime > Date() else { return nil }
                return token
            }
        }
    }
}

//MARK: Authentication.Token
extension AccessToken: Authentication.Token {
    
    typealias UserType = User
    static var userIDKey: WritableKeyPath<AccessToken, UUID> = \.userID
}
