//
//  InstructionsView.swift
//  onthisday
//
//  Created by Kevin Rapkin on 11/29/25.
//


import SwiftUI

struct InstructionsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("How to Play")
                    .font(.title2.weight(.semibold))

                Text("Goal")
                    .font(.headline)

                Text("""
Each day, you’re given a historical event that happened on this date. Your goal is to guess the 4-digit year when the event occurred.
""")

                Text("Guessing")
                    .font(.headline)

                Text("""
• Use the number buttons (0–9) to enter a 4-digit year.
• Tap “Guess” to submit.
• You get up to 6 guesses per day.
""")

                Text("Tile Colors (Wordle-style)")
                    .font(.headline)

                Text("""
• 🟩 Green: Correct digit in the correct position.
• 🟨 Yellow: Digit is in the year, but in a different position.
• ⬛️ Gray: Digit does not appear in the year.
""")

                Text("Results & Sharing")
                    .font(.headline)

                Text("""
• If you guess correctly within 6 tries, you win for the day.
• If you run out of guesses, the correct year is revealed.
• Use the “Copy result” button to copy a shareable grid (like Wordle) to paste into messages or social media.
""")

                Text("Stats")
                    .font(.headline)

                Text("""
• The Stats tab shows global stats for today (across all players).
• When you’re signed in, it also shows your own stats for today.
""")

                Text("Accounts")
                    .font(.headline)

                Text("""
• You can sign up or log in with an email and password.
• When logged in, your daily results contribute to your personal stats.
""")
            }
            .padding()
        }
        .navigationTitle("Instructions")
        .navigationBarTitleDisplayMode(.inline)
    }
}