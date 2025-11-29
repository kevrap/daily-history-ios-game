//
//  MainTabView.swift
//  onthisday
//
//  Created by Kevin Rapkin on 11/28/25.
//


import SwiftUI

struct MainTabView: View {
    let userId: String
    @StateObject private var gameViewModel: GameViewModel

    init(userId: String) {
        self.userId = userId
        _gameViewModel = StateObject(wrappedValue: GameViewModel(userId: userId))
    }

    var body: some View {
        TabView {
            NavigationStack {
                GameView(viewModel: gameViewModel)
            }
            .tabItem {
                Label("Today", systemImage: "calendar")
            }

            NavigationStack {
                StatsView(viewModel: gameViewModel)
            }
            .tabItem {
                Label("Stats", systemImage: "chart.bar")
            }
        }
    }
}