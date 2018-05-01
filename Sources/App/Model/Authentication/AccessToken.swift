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

public struct AccessToken: Content, SQLiteUUIDModel, Migration {
    public typealias Token = String
    
    //MARK: Constants
    static let accessTokenExpirationInterval: TimeInterval = 3600
    
    //MARK: Properties
    public var id: UUID?
    public let tokenString: Token
    public let userID: UUID
    public let expiryTime: Date
    
    //MARK: Initializers
    public init(userID: UUID) {
        self.tokenString = UUID().uuidString
        self.userID = userID
        self.expiryTime = Date().addingTimeInterval(AccessToken.accessTokenExpirationInterval)
    }
}
