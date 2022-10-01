//
//  AuthenticationSessionService.swift
//  Auth
//
//  Created by Will McGinty on 9/29/22.
//

import Foundation

class AuthenticationSessionService: ObservableObject {

    // MARK: - Properties
    private static let storageKey: String = "current_user"

    public let storage: AuthenticationSessionStorage
    @Published public var currentUser: User? {
        didSet {
            try? storage.set(currentUser, forKey: Self.storageKey)
        }
    }

    // MARK: - Initializer
    public init(storage: AuthenticationSessionStorage = UserDefaults.standard) {
        self.storage = storage
        self.currentUser = try? storage.get(forKey: Self.storageKey)
    }

    // MARK: - Interface
    public func logIn(with user: User) {
        currentUser = user
    }

    public func update(user: User) {
        currentUser = user
    }

    public func logOut() {
        currentUser = nil
    }
}

// MARK: - AuthenticationSessionStorage
public protocol AuthenticationSessionStorage {
    func set<T: Codable>(_ value: T?, forKey key: String) throws
    func get<T: Codable>(forKey key: String) throws -> T?
}

// MARK: - KeychainSwift + AuthenticationSessionStorage
extension UserDefaults: AuthenticationSessionStorage {

    public func set<T: Codable>(_ value: T?, forKey key: String) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(value)

        setValue(data, forKey: key)
    }

    public func get<T: Codable>(forKey key: String) throws -> T? {
        return try (value(forKey: key) as? Data).map {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: $0)
        }
    }
}
