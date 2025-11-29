//
//  RootView.swift
//  onthisday
//
//  Created by Kevin Rapkin on 11/28/25.
//


import SwiftUI

struct RootView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showSplash = true

    var body: some View {
        ZStack {
            if showSplash {
                SplashView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                showSplash = false
                            }
                        }
                    }
            } else if authViewModel.isAuthenticated {
                MainTabView(userId: authViewModel.userId ?? "")
            } else {
                AuthView()
            }
        }
    }
}