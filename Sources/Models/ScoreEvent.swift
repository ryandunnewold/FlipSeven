import Foundation

/// A single scoring event during the active game, shown in the activity feed.
struct ScoreEvent: Identifiable, Codable {
    let id: UUID
    let date: Date
    let round: Int
    let playerId: UUID
    let playerName: String
    let playerEmoji: String
    let playerColorIndex: Int
    /// Points added to the player's score (0 for a bust).
    let points: Int
    /// True when this player won the round (7-card hand).
    let isRoundWin: Bool
    let isBust: Bool

    init(round: Int, playerId: UUID, playerName: String, playerEmoji: String,
         playerColorIndex: Int, points: Int, isRoundWin: Bool, isBust: Bool) {
        self.id = UUID()
        self.date = Date()
        self.round = round
        self.playerId = playerId
        self.playerName = playerName
        self.playerEmoji = playerEmoji
        self.playerColorIndex = playerColorIndex
        self.points = points
        self.isRoundWin = isRoundWin
        self.isBust = isBust
    }
}
