//
//  GameView.swift
//  onthisday
//
//  Created by Kevin Rapkin on 11/22/25.
//


import SwiftUI

struct GameView: View {

    @StateObject private var viewModel = GameViewModel()
    @State private var showingStats = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                header
                descriptionSection
                boardSection
                inputSection
                statusSection
                shareSection
                Spacer()
                statsPreviewButton
            }
            .padding()
            .navigationTitle("On This Day")
            Text("Kevin Rapkin, Z15183142")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingStats = true
                    } label: {
                        Image(systemName: "chart.bar.doc.horizontal")
                    }
                }

                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        Task { await viewModel.loadTodayEvent() }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .sheet(isPresented: $showingStats) {
                StatsView(viewModel: viewModel)
            }
        }
    }

    // MARK: - Subviews

    private var header: some View {
        Text("Guess the year!")
            .font(.title2.weight(.semibold))
    }

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            switch viewModel.status {
            case .loading:
                ProgressView("Loading today’s event…")
            case .error(let message):
                Text(message)
                    .foregroundColor(.red)
            default:
                Text(viewModel.eventDescription)
                    .font(.body)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var boardSection: some View {
        VStack(spacing: 8) {
            ForEach(0..<viewModel.maxGuesses, id: \.self) { row in
                HStack(spacing: 8) {
                    if row < viewModel.guesses.count {
                        let guess = viewModel.guesses[row]
                        ForEach(0..<4, id: \.self) { i in
                            tileView(
                                char: charAt(guess.guess, index: i),
                                state: guess.result[i]
                            )
                        }
                    } else {
                        ForEach(0..<4, id: \.self) { _ in
                            tileView(char: "", state: .empty)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }

    private func tileView(char: String, state: TileState) -> some View {
        let bg: Color
        switch state {
        case .correct: bg = .green
        case .present: bg = .yellow
        case .absent:  bg = .gray.opacity(0.5)
        case .empty:   bg = .clear
        }

        return Text(char)
            .font(.title)
            .frame(width: 40, height: 40)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(Color.secondary, lineWidth: state == .empty ? 1 : 0)
                    .background(RoundedRectangle(cornerRadius: 8).fill(bg))
            )
            .foregroundColor(state == .empty ? .primary : .white)
    }

    private var inputSection: some View {
        HStack {
            TextField("Enter year (4 digits)", text: $viewModel.currentGuess)
                .keyboardType(.numberPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .disabled(!isPlaying)

            Button("Guess") {
                viewModel.submitGuess()
            }
            .disabled(!isPlaying || viewModel.currentGuess.trimmingCharacters(in: .whitespacesAndNewlines).count != 4)
        }
    }

    private var statusSection: some View {
        Group {
            switch viewModel.status {
            case .won:
                Text("🎉 Correct! It was \(viewModel.targetYearString).")
                    .foregroundColor(.green)
            case .lost:
                Text("😔 Out of guesses. The year was \(viewModel.targetYearString).")
                    .foregroundColor(.red)
            case .playing:
                Text("Guesses: \(viewModel.guesses.count)/\(viewModel.maxGuesses)")
                    .foregroundColor(.secondary)
            case .loading:
                EmptyView()
            case .error(let message):
                Text(message).foregroundColor(.red)
            }
        }
    }

    private var shareSection: some View {
        Group {
            if case .won = viewModel.status,
               !viewModel.shareText.isEmpty {
                Button {
                    viewModel.copyShareTextToPasteboard()
                } label: {
                    HStack {
                        Image(systemName: "square.and.arrow.up.on.square")
                        Text(viewModel.hasCopiedShareText ? "Copied!" : "Copy result")
                    }
                }
            }
        }
    }

    private var statsPreviewButton: some View {
        VStack(spacing: 4) {
            if let avg = viewModel.dailyAverageGuesses,
               let games = viewModel.dailyGamesPlayed,
               games > 0 {
                Text("Today’s global avg guesses: \(avg, specifier: "%.2f")")
                Text("Games played: \(games)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Text("No global stats yet for today.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
    }

    // Helpers

    private var isPlaying: Bool {
        if case .playing = viewModel.status { return true }
        return false
    }

    private func charAt(_ s: String, index: Int) -> String {
        guard index < s.count else { return "" }
        let idx = s.index(s.startIndex, offsetBy: index)
        return String(s[idx])
    }
}
