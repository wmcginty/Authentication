//
//  AuthorizationRefreshService.swift
//  Auth
//
//  Created by Will McGinty on 9/29/22.
//

import Combine
import Hyperspace
import SwiftUI

actor AuthorizationRefreshService: ObservableObject {

    // MARK: - Properties
    private var attemptsLocalValidation: Bool = true
    private var authentication: User.Authentication {
        didSet { objectWillChange.send() }
    }
    private var authenticationRefreshTask: Task<User.Authentication.AccessToken, Swift.Error>?

    private lazy var backendService: BackendServicing = Hyperspace.BackendService()

    // MARK: - Initializer
    public init(currentAuthentication: User.Authentication) {
        self.authentication = currentAuthentication
    }

    // MARK: - Interface
    public func attemptLocalTokenValidation(enabled: Bool) {
        attemptsLocalValidation = enabled
    }

    public func currentAuthentication() -> User.Authentication? {
        return authentication
    }

    public func accessToken(on requestDate: Date = .now, requireRefresh: Bool = false) async throws -> User.Authentication.AccessToken {
        if let existingRefresh = authenticationRefreshTask {
            return try await existingRefresh.value
        }

        guard !requireRefresh, !attemptsLocalValidation || authentication.isValid(on: requestDate) else {
            return try await refreshAuthentication(using: authentication)
        }

        return authentication.accessToken
    }
}

// MARK: - RecoveryStrategy
extension AuthorizationRefreshService: RecoveryStrategy {

    func attemptRecovery<R>(from error: Error, executing request: Hyperspace.Request<R>) async -> Hyperspace.RecoveryDisposition<Hyperspace.Request<R>> {
        guard let transportFailure = error as? TransportFailure,
              case let .clientError(clientError) = transportFailure.kind, clientError == .unauthorized,
              let updatedRequest = request.updatedForNextAttempt() else { return .notAttempted }

        do {
            let accessToken = try await accessToken(requireRefresh: true)
            let reauthenticated = updatedRequest.addingHeaders([.authorization: .authorizationBearer(token: accessToken)])
            return .retry(reauthenticated)

        } catch let refreshError {
            // In theory, you could return the error from refreshing, but we'll return the original error
            debugPrint("Error refreshing", refreshError)
            return .failure(error)
        }
    }
}

// MARK: - Helper
private extension AuthorizationRefreshService {

    func refreshAuthentication(using auth: User.Authentication) async throws -> User.Authentication.AccessToken {
        if let existingRefresh = authenticationRefreshTask {
            return try await existingRefresh.value
        }

        let refreshTask = Task { () throws -> User.Authentication.AccessToken in
            defer { authenticationRefreshTask = nil }

            let updatedAuth = try await backendService.execute(request: Endpoint.refreshAuthenticationRequest(with: auth.refreshToken), delegate: nil)
            authentication = updatedAuth

            return updatedAuth.accessToken
        }

        authenticationRefreshTask = refreshTask
        return try await refreshTask.value
    }
}
