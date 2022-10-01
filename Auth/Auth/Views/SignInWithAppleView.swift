//
//  SignInWithAppleView.swift
//  Auth
//
//  Created by Will McGinty on 9/30/22.
//

import AuthenticationServices
import SwiftUI
import CryptoKit

struct SignInWithAppleView: View {

    // MARK: - Properties
    let onCompletion: (User.Social) -> Void
    @State private var currentNonce: String?
    @State private var currentState: String?

    // MARK: - View
    var body: some View {
        SignInWithAppleButton { request in
            request.requestedScopes = [.email] // Could also request .fullName if it's needed
            
            let nonce = Data(CryptoKit.AES.GCM.Nonce()).base64EncodedString()
            request.nonce = nonce
            currentNonce = nonce
            
            let state = UUID().uuidString
            request.state = state
            currentState = state
            
        } onCompletion: {
            handleAppleSignInResult($0)
        }
    }
}

// MARK: - Helper
private extension SignInWithAppleView {

    func handleAppleSignInResult(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .failure(let error):
            guard let authorizationError = error as? ASAuthorizationError else { return }
            
            if ![.canceled, .unknown].contains(authorizationError.code) {
                debugPrint("Something went wrong: \(authorizationError)")
            }
            
        case .success(let authorization):
            guard let appleCredential = authorization.credential as? ASAuthorizationAppleIDCredential else { return }
            guard appleCredential.state == currentState, let email = appleCredential.email else { return }
            
            let userID = appleCredential.user
            debugPrint("User ID: \(userID)")
            debugPrint("Email: \(email)")
            
            if appleCredential.realUserStatus == .likelyReal {
                debugPrint("Real User Status: Likely Real")
            }
            
            let socialUser = User.Social(email: email, userID: userID, identityToken: appleCredential.identityToken,
                                         authorizationCode: appleCredential.authorizationCode, nonce: currentNonce)
            onCompletion(socialUser)
        }
    }
}
