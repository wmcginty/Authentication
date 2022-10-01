//
//  AuthApp.swift
//  Auth
//
//  Created by Will McGinty on 9/29/22.
//

import SwiftUI

@main
struct AuthApp: App {
    
    @StateObject private var viewModel = AppViewModel()
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContentView(viewModel: viewModel)
                    .task { viewModel.loadPersisted() }
            }
            .task { viewModel.reverifySignInWithAppleCredential() }
        }
    }
}
