//
//  GameViewModal.swift
//  onthisday
//
//  Created by Kevin Rapkin on 11/22/25.
//

import Foundation
import SwiftUI
import FirebaseFirestore

#if canImport(UIKit)
import UIKit
#endif

// MARK: - Wordle-like tile state

enum TileState {
    case empty
    case correct
    case present
    case absent
}

// One guess row
struct Guess: Identifiable {
    let id = UUID()
    let guess: String   // "1985"
    let result: [TileState]  // 4 entries
}

// MARK: - On This Day API models

struct OnThisDayResponse: Decodable {
    let events: [OnThisDayEvent]
}

struct OnThisDayEvent: Decodable {
    /// Raw year string from the API, e.g. "1969", "69 BC", "AD 476"
    let rawYear: String
    let description: String

    /// Try to convert the raw year into a plain Int (for the guessing game)
    var numericYear: Int? {
        // Remove BC/AD text, keep digits
        let cleaned = rawYear
            .uppercased()
            .replacingOccurrences(of: "BC", with: "")
            .replacingOccurrences(of: "AD", with: "")

        let digitsOnly = cleaned.filter { $0.isNumber }
        guard !digitsOnly.isEmpty, let value = Int(digitsOnly) else {
            return nil
        }
        return value
    }

    enum CodingKeys: String, CodingKey {
        case year
        case description
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Accept either Int or String for "year"
        if let intYear = try? container.decode(Int.self, forKey: .year) {
            self.rawYear = String(intYear)
        } else {
            self.rawYear = try container.decode(String.self, forKey: .year)
        }

        self.description = try container.decode(String.self, forKey: .description)
    }
}

// MARK: - Game status

enum GameStatus {
    case loading
    case playing
    case won
    case lost
    case error(String)
}

// MARK: - ViewModel

@MainActor
class GameViewModel: ObservableObject {

    // Publicly observed properties
    @Published var eventDescription: String = ""
    @Published var targetYearString: String = ""  // "1985"
    @Published var guesses: [Guess] = []
    @Published var currentGuess: String = ""
    @Published var status: GameStatus = .loading

    // Firestore stats
    @Published var dailyAverageGuesses: Double?
    @Published var dailyGamesPlayed: Int?
    @Published var dailyWinRate: Double?

    // Share text
    @Published var hasCopiedShareText: Bool = false

    let maxGuesses = 6
    private var hasSubmittedScore = false

    private let db = Firestore.firestore()

    init() {
        Task {
            await loadTodayEvent()
            listenToTodayStats()
        }
    }

    // MARK: - API: Load today's event from Wikipedia-derived API

    func loadTodayEvent() async {
        status = .loading

        let today = Date()
        let calendar = Calendar.current
        let month = calendar.component(.month, from: today)
        let day = calendar.component(.day, from: today)

        guard let url = URL(string: "https://byabbe.se/on-this-day/\(month)/\(day)/events.json") else {
            status = .error("Bad URL")
            return
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            if let http = response as? HTTPURLResponse {
                print("OnThisDay HTTP status:", http.statusCode)
            }

            let decoded = try JSONDecoder().decode(OnThisDayResponse.self, from: data)

            // Filter to events with a numeric year between 1000–2025
            let candidates: [(year: Int, description: String)] = decoded.events.compactMap { event in
                guard let y = event.numericYear, y >= 1000 && y <= 2025 else { return nil }
                return (y, event.description)
            }

            guard let chosen = candidates.randomElement() else {
                status = .error("No suitable events for today")
                return
            }

            self.eventDescription = chosen.description
            self.targetYearString = String(chosen.year)
            self.guesses = []
            self.currentGuess = ""
            self.hasSubmittedScore = false
            self.status = .playing

        } catch {
            print("Error loading OnThisDay:", error)
            status = .error("Failed to load event. \(error.localizedDescription)")
        }
    }
    // MARK: - Game logic

    func submitGuess() {
        guard case .playing = status else { return }
        let trimmed = currentGuess.trimmingCharacters(in: .whitespacesAndNewlines)

        // Must be exactly 4 digits
        guard trimmed.count == 4, trimmed.allSatisfy({ $0.isNumber }) else {
            // You could put a user-facing validation message here
            return
        }

        let evaluation = evaluate(guess: trimmed, against: targetYearString)
        let newGuess = Guess(guess: trimmed, result: evaluation)
        guesses.append(newGuess)
        currentGuess = ""

        if trimmed == targetYearString {
            status = .won
            submitResultToFirestore(didWin: true)
        } else if guesses.count >= maxGuesses {
            status = .lost
            submitResultToFirestore(didWin: false)
        }
    }

    private func evaluate(guess: String, against target: String) -> [TileState] {
        let g = Array(guess)
        let t = Array(target)
        var result = Array(repeating: TileState.absent, count: 4)
        var unmatchedTargetCounts: [Character: Int] = [:]

        // First pass – exact matches
        for i in 0..<4 {
            if g[i] == t[i] {
                result[i] = .correct
            } else {
                unmatchedTargetCounts[t[i], default: 0] += 1
            }
        }

        // Second pass – present but wrong place
        for i in 0..<4 where result[i] != .correct {
            let c = g[i]
            if let count = unmatchedTargetCounts[c], count > 0 {
                result[i] = .present
                unmatchedTargetCounts[c] = count - 1
            } else {
                result[i] = .absent
            }
        }

        return result
    }

    // MARK: - Share text

    var shareText: String {
        guard !guesses.isEmpty else { return "" }
        var lines: [String] = []
        let header = "OnThisDayle \(guesses.count)/\(maxGuesses)"
        lines.append(header)

        for guess in guesses {
            let line = guess.result.map { tile -> String in
                switch tile {
                case .correct: return "🟩"
                case .present: return "🟨"
                case .absent, .empty: return "⬛️"
                }
            }.joined()
            lines.append(line)
        }

        return lines.joined(separator: "\n")
    }

    // We can’t literally import UIKit inside a method, so we’ll add this as a helper in an extension below.
    // See extension GameViewModel at bottom of file.

    // MARK: - Firestore: submit + listen to stats

    private func submitResultToFirestore(didWin: Bool) {
        guard !hasSubmittedScore else { return }
        hasSubmittedScore = true

        let dateKey = Self.todayKey()
        let docRef = db.collection("dailyStats").document(dateKey)

        let guessCount = guesses.count

        docRef.setData([
            "date": dateKey,
            "gamesPlayed": FieldValue.increment(Int64(1)),
            "totalGuesses": FieldValue.increment(Int64(guessCount)),
            "totalWins": FieldValue.increment(Int64(didWin ? 1 : 0))
        ], merge: true) { error in
            if let error = error {
                print("Error writing stats: \(error)")
            }
        }
    }

    private func listenToTodayStats() {
        let dateKey = Self.todayKey()
        let docRef = db.collection("dailyStats").document(dateKey)

        docRef.addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }
            if let error = error {
                print("Error listening to stats:", error)
                return
            }
            guard let data = snapshot?.data() else { return }

            let games = Self.intFrom(data["gamesPlayed"])
            let totalGuesses = Self.intFrom(data["totalGuesses"])
            let totalWins = Self.intFrom(data["totalWins"])

            DispatchQueue.main.async {
                self.dailyGamesPlayed = games
                self.dailyAverageGuesses = games > 0 ? Double(totalGuesses) / Double(games) : nil
                self.dailyWinRate = games > 0 ? Double(totalWins) / Double(games) : nil
            }
        }
    }

    // Helpers

    private static func todayKey() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }

    private static func intFrom(_ value: Any?) -> Int {
        if let i = value as? Int { return i }
        if let i64 = value as? Int64 { return Int(i64) }
        if let d = value as? Double { return Int(d) }
        if let n = value as? NSNumber { return n.intValue }
        return 0
    }
}

// MARK: - UIKit pasteboard helper in an extension

#if canImport(UIKit)
extension GameViewModel {
    func copyShareTextToPasteboard() {
        let text = shareText
        guard !text.isEmpty else { return }
        UIPasteboard.general.string = text
        hasCopiedShareText = true
    }
}
#else
extension GameViewModel {
    func copyShareTextToPasteboard() {
        // No-op on platforms without UIKit
    }
}
#endif
