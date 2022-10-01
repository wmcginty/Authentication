//
//  ContentView.swift
//  Auth
//
//  Created by Will McGinty on 9/29/22.
//

import AuthenticationServices
import SwiftUI
import CryptoKit

struct ContentView: View {

    // MARK: - Properties
    @ObservedObject var viewModel: AppViewModel
    @State private var currentAuthentication: User.Authentication?
    @State private var locallyValidateToken: Bool = true
    @State private var authenticationCheckResult: Bool?
    
    // MARK: - View
    var body: some View {
        List {
            if viewModel.isLoggedIn, let currentUserEmail = viewModel.loggedInEmail {
                VStack(alignment: .leading) {
                    Text("Logged In User")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(currentUserEmail)
                }

                if let currentAuthentication {
                    VStack(alignment: .leading) {
                        Text("Access Token Expiration")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text(currentAuthentication.expirationDate.formatted(date: .long, time: .standard))
                    }
                }

                Toggle("Locally Validate Token", isOn: $locallyValidateToken)

                Button(action: checkAuthentication) {
                    VStack(alignment: .leading) {
                        Text("Check Authentication Status")
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        if let authenticationCheckResult {
                            Text(authenticationCheckResult ? "Passed at \(Date.now.formatted())": "Failed at \(Date.now.formatted())")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .animation(.default, value: authenticationCheckResult)
                }

                Button(action: { viewModel.logOut() }) {
                    Text("Log Out")
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

            } else {
                Section {
                    NavigationLink("Log In") {
                        AuthenticationView(viewModel: viewModel)
                    }
                }
            }
        }
        .navigationTitle("Home")
        .onReceive(NotificationCenter.default.publisher(for: ASAuthorizationAppleIDProvider.credentialRevokedNotification)) { _ in viewModel.logOut() }
        .onReceive(viewModel.objectWillChange) {
            Task { currentAuthentication = await viewModel.apiClient.currentAuthentication() }
        }
        .onChange(of: locallyValidateToken) { shouldLocallyValidate in
            Task { await viewModel.apiClient.attemptLocalTokenValidation(enabled: shouldLocallyValidate) }
        }
        .task {
            currentAuthentication = await viewModel.apiClient.currentAuthentication()
        }
    }
}

// MARK: - Helper
private extension ContentView {
    
    func checkAuthentication() {
        Task {
            do {
                try await viewModel.apiClient.checkAuthentication()
                authenticationCheckResult = true

            } catch {
                authenticationCheckResult = false
            }

            await clearAuthenticationCheckResult()
        }
    }

    func clearAuthenticationCheckResult() async {
        try? await Task.sleep(until: .now + .seconds(5), clock: .continuous)
        authenticationCheckResult = nil
    }
}

// MARK: - Previews
struct ContentView_Previews: PreviewProvider, View {

    @StateObject private var viewModel = AppViewModel()

    var body: some View {
        NavigationStack {
            ContentView(viewModel: viewModel)
        }
    }

    static var previews: some View {
        ContentView_Previews()
    }
}
