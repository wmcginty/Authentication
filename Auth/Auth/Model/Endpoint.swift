//
//  Endpoint.swift
//  Auth
//
//  Created by Will McGinty on 9/29/22.
//

import Foundation
import Hyperspace

public enum Endpoint {
    case register
    case login
    case signInWithApple
    case refresh
    case check
    
    // MARK: - Properties
    private static let baseURL = URL(string: "http://localhost:8080")!
    
    // MARK: - Interface
    var url: URL {
        var components = URLComponents(url: Self.baseURL, resolvingAgainstBaseURL: false)
        components?.path = path

        guard let url = components?.url else {
            fatalError("Developer Error: URL for \(self) could not be created.")
        }

        return url
    }
    
    var path: String {
        switch self {
        case .register: return "/api/users/register"
        case .login: return "/api/users/login"
        case .signInWithApple: return "/api/users/login/apple"
        case .refresh: return "/api/token/refresh"
        case .check: return "/api/protected/token"
        }
    }
}

// MARK: - Endpoint + Auth
extension Endpoint {

    static func registerUserRequest(for credentials: User.Credentials) throws -> Request<User> {
        return Request(method: .post, url: Endpoint.register.url, body: try .json(credentials))
            .map { User(email: credentials.email, appleUserID: nil, authentication: $0) }
    }

    static func loginRequest(with credentials: User.Credentials) throws -> Request<User> {
        let authHeader = HTTP.HeaderValue.authorizationBasic(username: credentials.email, password: credentials.password)
            .map { [HTTP.HeaderKey.authorization: $0] }
        return Request(url: Endpoint.login.url, headers: authHeader)
            .map { User(email: credentials.email, appleUserID: nil, authentication: $0) }
    }
    
    static func signInWithAppleRequest(with registrant: User.Social) throws -> Request<User> {
        return Request(method: .post, url: Endpoint.signInWithApple.url, body: try .json(registrant))
            .map { User(email: registrant.email, appleUserID: registrant.userID, authentication: $0) }
    }

    static func refreshAuthenticationRequest(with token: User.Authentication.RefreshToken) throws -> Request<User.Authentication> {
        struct RefreshContainer: Encodable {
            let refreshToken: String
        }

        return Request(method: .post, url: Endpoint.refresh.url, body: try .json(RefreshContainer(refreshToken: token)))
    }

    static func checkAuthenticationRequest() throws -> Request<Void> {
        return Request.withEmptyResponse(url: Endpoint.check.url)
    }
}
