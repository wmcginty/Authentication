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

public struct RefreshToken: Content, SQLiteUUIDModel, Migration {
    public typealias Token = String
    
    //MARK: Properties
    public var id: UUID?
    public let tokenString: Token
    public let userID: UUID
    
    //MARK: Initializers
    public init(userID: UUID) {
        self.tokenString = UUID().uuidString
        self.userID = userID
    }
}
