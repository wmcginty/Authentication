//
//  APIClient.swift
//  Auth
//
//  Created by Will McGinty on 9/29/22.
//

import Combine
import Foundation
import Hyperspace

final class APIClient: ObservableObject {

    // MARK: - Properties
    private let authorizationRefreshService: AuthorizationRefreshService?
    private let backendService: any BackendServicing
    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Initializers
    init(sessionConfiguration: URLSessionConfiguration = .default, currentAuthentication: User.Authentication? = nil) {
        self.authorizationRefreshService = currentAuthentication.map { .init(currentAuthentication: $0) }

        let backendService = Hyperspace.BackendService(transportService: TransportService(sessionConfiguration: sessionConfiguration))
        if let authorizationRefreshService {
            backendService.recoveryStrategies.append(authorizationRefreshService)
        }

        self.backendService = backendService
        self.authorizationRefreshService?.objectWillChange.sink { [weak self] in
            self?.objectWillChange.send()
        }.store(in: &cancellables)
    }

    // MARK: - Interface
    func attemptLocalTokenValidation(enabled: Bool) async {
        await authorizationRefreshService?.attemptLocalTokenValidation(enabled: enabled)
    }

    func currentAuthentication() async -> User.Authentication? {
        return await authorizationRefreshService?.currentAuthentication()
    }

    func execute<T>(request: Request<T>) async throws -> T {
        return try await backendService.execute(request: request, delegate: nil)
    }
}

// MARK: - Auth
extension APIClient {

    func registerUser(for credentials: User.Credentials) async throws -> User {
        return try await execute(request: Endpoint.registerUserRequest(for: credentials))
    }
    
    func signInWithApple(with registrant: User.Social) async throws -> User {
        return try await execute(request: Endpoint.signInWithAppleRequest(with: registrant))
    }

    func login(with credentials: User.Credentials) async throws -> User {
        return try await execute(request: Endpoint.loginRequest(with: credentials))
    }

    func checkAuthentication() async throws {
        let checkRequest = try Endpoint.checkAuthenticationRequest()
        let authorizedCheckRequest = try await authorizedRequest(for: checkRequest)
        return try await execute(request: authorizedCheckRequest)
    }
}

// MARK: - Helper
extension APIClient {

    func authorizedRequest<T>(for request: Request<T>) async throws -> Request<T> {
        guard let authorizationRefreshService else {
            // There is no `authorizationRefreshService`, the user is likely not logged in. The request won't be authorized, so will likely result in a 401.
            return request
        }
        
        let accessToken = try await authorizationRefreshService.accessToken()
        return request.addingHeaders([.authorization: .authorizationBearer(token: accessToken)])
    }
}
