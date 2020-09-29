//
//  RoutesBuilder+Utility.swift
//  
//
//  Created by William McGinty on 9/28/20.
//

import Vapor

extension RoutesBuilder {
    
    func tokenAuthenticated(required: Bool = true) -> RoutesBuilder {
        return required ? grouped(AccessToken.authenticator(), AccessToken.guardMiddleware()) : grouped(AccessToken.authenticator())
    }
    
    @discardableResult
    func post<T: Content, Response: ResponseEncodable>(_ contentType: T.Type, path: PathComponent..., use: @escaping (Request, T) throws -> Response) -> Route {
        return post(path) { request -> Response in
            let content = try request.content.decode(T.self)
            return try use(request, content)
        }
    }
}
