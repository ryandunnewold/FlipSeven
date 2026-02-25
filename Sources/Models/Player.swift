import SwiftUI

struct Player: Identifiable, Codable {
    let id: UUID
    var name: String
    var emoji: String
    var colorIndex: Int

    // Lifetime records — accumulated across all completed games
    var gamesPlayed: Int = 0
    var gamesWon: Int = 0
    var totalRoundWins: Int = 0
    var totalBusts: Int = 0

    init(name: String, emoji: String = "🦄", colorIndex: Int = 0) {
        self.id = UUID()
        self.name = name
        self.emoji = emoji
        self.colorIndex = colorIndex
    }

    static let themeColors: [Color] = [.flipPink, .flipPurple, .flipBlue, .flipGreen]

    var themeColor: Color {
        Self.themeColors[colorIndex % Self.themeColors.count]
    }
}
