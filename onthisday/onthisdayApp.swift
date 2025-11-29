//
//  onthisdayApp.swift
//  onthisday
//
//  Created by Kevin Rapkin on 11/22/25.
//

import SwiftUI
import FirebaseCore

@main
struct OnThisDayleApp: App {

    @StateObject private var authViewModel = AuthViewModel()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authViewModel)
        }
    }
}
