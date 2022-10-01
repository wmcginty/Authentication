//
//  AppViewModel.swift
//  Auth
//
//  Created by Will McGinty on 9/29/22.
//

import Foundation
import SwiftUI
import AuthenticationServices

@MainActor
class AppViewModel: ObservableObject {

    // MARK: - Properties
    @Published var loggedInEmail: String?

    private(set) var apiClient: APIClient
    private lazy var authenticationSessionService = AuthenticationSessionService()

    // MARK: - Initializer
    init(currentUser: User? = nil) {
        self.loggedInEmail = currentUser?.email
        self.apiClient = APIClient(currentAuthentication: currentUser?.authentication)
    }

    // MARK: - Interface
    var isLoggedIn: Bool {
        return loggedInEmail != nil
    }
}

// MARK: - Data Loading / Saving
extension AppViewModel {

    func loadPersisted() {
        let persistedUser = authenticationSessionService.currentUser
        guard let userID = authenticationSessionService.currentUser?.appleUserID else {
            return handleChange(to: persistedUser)
        }
        
        let provider = ASAuthorizationAppleIDProvider()
        provider.getCredentialState(forUserID: userID) { [weak self] state, error in
            switch state {
            case .authorized: self?.handleChange(to: persistedUser)
            default: self?.handleChange(to: nil)
            }
        }
    }
}

// MARK: - Authentication
extension AppViewModel {

    func register(with credentials: User.Credentials) async throws {
        let registeredUser = try await apiClient.registerUser(for: credentials)
        handleChange(to: registeredUser)
    }

    func login(with credentials: User.Credentials) async throws {
        let loggedInUser = try await apiClient.login(with: credentials)
        handleChange(to: loggedInUser)
    }
    
    func signInWithApple(with registrant: User.Social) async throws {
        let loggedInUser = try await apiClient.signInWithApple(with: registrant)
        handleChange(to: loggedInUser)
    }

    func logOut() {
        handleChange(to: nil)
    }
}

// MARK: - Helper
private extension AppViewModel {

    func handleChange(to user: User?) {
        loggedInEmail = user?.email
        apiClient = APIClient(currentAuthentication: user?.authentication)

        persistChanges(to: user)
    }

    func persistChanges(to user: User?) {
        authenticationSessionService.currentUser = user
    }
}
