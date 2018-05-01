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

struct RefreshToken: Content, SQLiteUUIDModel, Migration {
    typealias Token = String
    
    //MARK: Properties
    var id: UUID?
    let tokenString: Token
    let userID: UUID
    
    //MARK: Initializers
    init(userID: UUID) throws {
        self.tokenString = try CryptoRandom().generateData(count: 32).base64URLEncodedString()
        self.userID = userID
    }
}
