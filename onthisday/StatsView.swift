//
//  StatsView.swift
//  onthisday
//
//  Created by Kevin Rapkin on 11/22/25.
//


import SwiftUI

struct StatsView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        VStack(spacing: 24) {
            Text("Today’s Global Stats")
                .font(.title2.weight(.semibold))

            GroupBox {
                statRow(title: "Games Played", value: viewModel.dailyGamesPlayed.map { "\($0)" } ?? "—")
                Divider()
                statRow(title: "Average Guesses", value: viewModel.dailyAverageGuesses.map { String(format: "%.2f", $0) } ?? "—")
                Divider()
                statRow(title: "Win Rate", value: viewModel.dailyWinRate.map { String(format: "%.0f%%", $0 * 100) } ?? "—")
            }

            Text("Your Stats (Today)")
                .font(.title3.weight(.semibold))

            GroupBox {
                statRow(title: "Games Played", value: viewModel.userDailyGamesPlayed.map { "\($0)" } ?? "—")
                Divider()
                statRow(title: "Average Guesses", value: viewModel.userDailyAverageGuesses.map { String(format: "%.2f", $0) } ?? "—")
                Divider()
                statRow(title: "Win Rate", value: viewModel.userDailyWinRate.map { String(format: "%.0f%%", $0 * 100) } ?? "—")
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Stats")
    }

    private func statRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
        }
    }
}
