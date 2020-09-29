//
//  Future+Utility.swift
//  
//
//  Created by William McGinty on 9/28/20.
//

import Vapor

extension EventLoopFuture {
    
    func throwingMap<NewValue>(callback: @escaping (Value) throws -> NewValue) -> EventLoopFuture<NewValue> {
        return flatMapThrowing(callback)
    }
    
    func throwingFlatMap<NewValue>(callback: @escaping (Value) throws -> EventLoopFuture<NewValue>) -> EventLoopFuture<NewValue> {
        return flatMap {
            do {
                return try callback($0)
            } catch {
                return self.eventLoop.makeFailedFuture(error)
            }
        }
    }
}

extension EventLoopFuture where Value: Collection {
    
    func throwingFlatMapEach<NewValue>(callback: @escaping (Value.Element) throws -> EventLoopFuture<NewValue>) -> EventLoopFuture<[NewValue]> {
        return throwingFlatMap { elements in
            return try elements.map(callback).flatten(on: self.eventLoop)
        }
    }
}

