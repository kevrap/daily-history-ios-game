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
        NavigationStack {
            VStack(spacing: 16) {
                if let games = viewModel.dailyGamesPlayed,
                   let avg = viewModel.dailyAverageGuesses {
                    Text("Today’s global stats")
                        .font(.title2.weight(.semibold))

                    Text("Games played: \(games)")
                    Text("Average guesses: \(avg, specifier: "%.2f")")

                    if let winRate = viewModel.dailyWinRate {
                        Text("Win rate: \(Int(winRate * 100))%")
                    }
                } else {
                    Text("No stats yet for today.")
                        .foregroundColor(.secondary)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Stats")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        // sheet is dismissed by parent binding
                        // (no direct dismissal needed here)
                    }
                }
            }
        }
    }
}