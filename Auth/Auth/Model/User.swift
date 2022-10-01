//
//  User.swift
//  Auth
//
//  Created by Will McGinty on 9/29/22.
//

import Foundation

struct User: Codable, Equatable {

    // MARK: - Credentials Subtype
    struct Credentials: Codable, Equatable {

        // MARK: - Properties
        var email: String
        var password: String
    }
    
    public struct Social: Codable, Equatable {
        
        // MARK: - Properties
        let email: String
        let userID: String
        let identityToken: Data?
        let authorizationCode: Data?
        let nonce: String?
    }

    // MARK: - Authentication Subtype
    struct Authentication: Codable, Equatable {
        
        typealias AccessToken = String
        typealias RefreshToken = String

        // MARK: - Properties
        let accessToken: AccessToken
        let refreshToken: RefreshToken
        let expiresIn: TimeInterval
        let creationDate: Date

        // MARK: - Initializer
        init(accessToken: String, refreshToken: String, expiresIn: TimeInterval, creationDate: Date = Date()) {
            self.accessToken = accessToken
            self.refreshToken = refreshToken
            self.expiresIn = expiresIn
            self.creationDate = creationDate
        }

        // MARK: - Interface
        var expirationDate: Date {
            return creationDate.advanced(by: expiresIn)
        }
        
        func isValid(on date: Date) -> Bool {
            return expirationDate > date
        }

        // MARK: - Codable
        private enum CodingKeys: String, CodingKey {
            case accessToken = "access_token"
            case expiresIn = "expires_in"
            case refreshToken = "refresh_token"
            case creationDate = "creation_date"
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.init(accessToken: try container.decode(AccessToken.self, forKey: .accessToken),
                      refreshToken: try container.decode(RefreshToken.self, forKey: .refreshToken),
                      expiresIn: try container.decode(TimeInterval.self, forKey: .expiresIn),
                      creationDate: try container.decodeIfPresent(Date.self, forKey: .creationDate) ?? .now)
        }
    }

    // MARK: - Properties
    let email: String
    let appleUserID: String?
    var authentication: Authentication
}
