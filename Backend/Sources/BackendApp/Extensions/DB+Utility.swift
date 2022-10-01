//
//  DB+Utility.swift
//  
//
//  Created by William McGinty on 9/28/20.
//

import Fluent

// MARK: DB Transactions
extension Model {
    
    static func existing(matching: ModelValueFilter<Self>, on database: Database) async throws -> Self? {
        return try await Self.query(on: database).filter(matching).first()
    }
    
    static func isExisting(matching: ModelValueFilter<Self>, on database: Database) async throws -> Bool {
        return try await existing(matching: matching, on: database) != nil
    }
}
