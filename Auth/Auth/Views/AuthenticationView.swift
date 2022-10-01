//
//  AuthenticationView.swift
//  Auth
//
//  Created by Will McGinty on 9/29/22.
//

import Hyperspace
import SwiftUI

struct AuthenticationView: View {

    // MARK: - Error Subtype
    private enum AuthenticationError: LocalizedError {
        case incorrectCredentials
        case other

        var errorDescription: String? {
            switch self {
            case .incorrectCredentials: return "Your username or password was incorrect."
            case .other: return "Something went wrong. Please try again later."
            }
        }
    }

    // MARK: - Properties
    @ObservedObject var viewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var isPresentingErrorAlert: Bool = false
    @State private var authenticationError: AuthenticationError?

    @State private var email: String = ""
    @State private var password: String = ""

    // MARK: - View
    var body: some View {
        Form {
            Section {
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)

                SecureField("Password", text: $password)
                    .textContentType(.password)
            }
            .autocorrectionDisabled()
            .autocapitalization(.none)

            Section {
                Group {
                    Button(AuthenticationState.logIn.description, action: login)
                    Button(AuthenticationState.register.description, action: register)
                }
                .disabled(email.isEmpty || password.isEmpty)
            }
            
            Section(header: Text("-- or --").frame(maxWidth: .infinity)) {
                SignInWithAppleView(onCompletion: signInWithApple(using:))
                    .listRowInsets(.init())
            }
        }
        .alert(isPresented: $isPresentingErrorAlert, error: authenticationError, actions: { })
        .navigationTitle("Authentication")
    }
}

// MARK: - Helper
private extension AuthenticationView {
    
    func register() {
        Task {
            do {
                let credentials = User.Credentials(email: email, password: password)
                try await viewModel.register(with: credentials)
                dismiss()

            } catch {
                authenticationError = .other
                isPresentingErrorAlert = true
            }
        }
    }

    func login() {
        Task {
            do {
                let credentials = User.Credentials(email: email, password: password)
                try await viewModel.login(with: credentials)
                dismiss()

            } catch let error as TransportFailure {
                if error.response?.status == .clientError(.unauthorized) {
                    authenticationError = .incorrectCredentials
                } else {
                    authenticationError = .other
                }
                isPresentingErrorAlert = true
            } catch {
                authenticationError = .other
                isPresentingErrorAlert = true
            }
        }
    }
    
    func signInWithApple(using registrant: User.Social) {
        Task {
            do {
                try await viewModel.signInWithApple(with: registrant)
                dismiss()
                
            } catch {
                authenticationError = .other
                isPresentingErrorAlert = true
            }
        }
    }

}

// MARK: - AuthenticationState Subtype
extension AuthenticationView {
    
    enum AuthenticationState: String, CustomStringConvertible {
        case register, logIn
        
        var description: String {
            switch self {
            case .logIn: return "Log In"
            case .register: return "Register"
            }
        }
    }
}

// MARK: - Previews
struct AuthenticationView_Previews: PreviewProvider, View {

    @StateObject private var viewModel = AppViewModel()

    var body: some View {
        NavigationStack {
            AuthenticationView(viewModel: viewModel)
        }
    }

    static var previews: some View {
        AuthenticationView_Previews()
    }
}
