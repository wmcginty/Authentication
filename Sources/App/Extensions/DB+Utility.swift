//
//  DB+Utility.swift
//  
//
//  Created by William McGinty on 9/28/20.
//

import Fluent

// MARK: DB Transactions
extension Model {
    
    static func isExisting(matching: ModelValueFilter<Self>, on database: Database) async throws -> Bool {
        return try await Self.query(on: database).filter(matching).count() == 0 ? true : false
    }
}
