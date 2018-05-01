//
//  User.swift
//  App
//
//  Created by William McGinty on 3/21/18.
//

import Foundation
import Vapor
import Fluent
import FluentSQLite

struct User: Content, SQLiteUUIDModel, Migration {
    
    //MARK: Properties
    var id: UUID?
    let email: String
    let password: String
}
