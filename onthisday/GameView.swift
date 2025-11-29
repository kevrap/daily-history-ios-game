//
//  GameView.swift
//  onthisday
//
//  Created by Kevin Rapkin on 11/22/25.
//


import SwiftUI

struct GameView: View {

    @ObservedObject var viewModel: GameViewModel
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        VStack(spacing: 16) {
            header
            descriptionSection
            boardSection
            numberPadSection
            statusSection
            shareSection
            Spacer()
        }
        .padding()
        .toolbar {
            // Center title as logo
            ToolbarItem(placement: .principal) {
                Image("OnThisDayTitle")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)    // tweak size as you like
            }

            // Refresh button on the left
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    Task { await viewModel.loadTodayEvent() }
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
            }

            // Sign out on the right (if you're using it)
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                            authViewModel.signOut()
                        } label: {
                            Text("Sign Out")
                        }
            }
        }
    }

    // MARK: - Subviews

    private var header: some View {
        Text("Guess the year of this event")
            .font(.title3.weight(.semibold))
            .multilineTextAlignment(.center)
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
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)                         // no line limit
                    .fixedSize(horizontal: false, vertical: true) // allow full height
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 8)
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

    // New: numeric keypad instead of text field
    private var numberPadSection: some View {
        VStack(spacing: 8) {
            Text(viewModel.currentGuess)
                .font(.title2.monospacedDigit())
                .frame(height: 30)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 5), spacing: 8) {
                ForEach(0..<10) { n in
                    Button("\(n)") {
                        viewModel.appendDigit(n)
                    }
                    .frame(height: 44)
                    .frame(maxWidth: .infinity)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                }
            }

            HStack {
                Button("Clear") {
                    viewModel.clearGuess()
                }
                .frame(maxWidth: .infinity)
                .padding(8)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)

                Button("Guess") {
                    viewModel.submitGuess()
                }
                .frame(maxWidth: .infinity)
                .padding(8)
                .background(isPlaying && viewModel.currentGuess.count == 4 ? Color.accentColor : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(8)
                .disabled(!isPlaying || viewModel.currentGuess.count != 4)
            }
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
