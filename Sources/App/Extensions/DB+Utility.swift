//
//  DB+Utility.swift
//  
//
//  Created by William McGinty on 9/28/20.
//

import Fluent

// MARK: DB Transactions
extension Model {
    
    func saveAndReturn(on database: Database) -> EventLoopFuture<Self> {
        return save(on: database).transform(to: self)
    }
    
    func createAndReturn(on database: Database) -> EventLoopFuture<Self> {
        return create(on: database).transform(to: self)
    }
    
    func updateAndReturn(on database: Database) -> EventLoopFuture<Self> {
        return update(on: database).transform(to: self)
    }
    
    static func isExisting(matching: ModelValueFilter<Self>, on database: Database) -> EventLoopFuture<Bool> {
        return Self.query(on: database).filter(matching).count().map { $0 == 0 ? true : false }
    }
}
