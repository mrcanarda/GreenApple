//
//  GreenAppleApp.swift
//  GreenApple
//
//  Created by Can Arda on 27.02.26.
//

import SwiftUI
import Firebase

@main
struct GreenAppleApp: App {
    @StateObject private var viewModel = AppViewModel()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            if viewModel.isLoggedIn {
                HomeView()
                    .environmentObject(viewModel)
            } else {
                AuthView()
                    .environmentObject(viewModel)
            }
        }
    }
}
