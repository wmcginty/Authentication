//
//  RefreshToken.swift
//  App
//
//  Created by William McGinty on 3/22/18.
//

import Foundation
import Vapor
import Fluent
import FluentSQLite
import Crypto

public struct RefreshToken: Content, SQLiteUUIDModel, Migration {
    public typealias Token = String
    
    //MARK: Properties
    public var id: UUID?
    public let tokenString: Token
    public let userID: UUID
    
    //MARK: Initializers
    public init(userID: UUID) throws {
        self.tokenString = try CryptoRandom().generateData(count: 32).base64URLEncodedString()
        self.userID = userID
    }
}
