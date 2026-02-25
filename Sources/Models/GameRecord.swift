import Foundation

/// A completed game saved to history.
struct GameRecord: Identifiable, Codable {
    let id: UUID
    let date: Date
    let roundsPlayed: Int
    let players: [PlayerSnapshot]
    /// Score events from that game, for the per-game activity view.
    let events: [ScoreEvent]

    var winner: PlayerSnapshot? { players.first { $0.isWinner } }

    struct PlayerSnapshot: Identifiable, Codable {
        let id: UUID
        let name: String
        let emoji: String
        let colorIndex: Int
        let finalScore: Int
        let roundWins: Int
        let busts: Int
        let isWinner: Bool
    }

    init(roundsPlayed: Int, players: [PlayerSnapshot], events: [ScoreEvent]) {
        self.id = UUID()
        self.date = Date()
        self.roundsPlayed = roundsPlayed
        self.players = players
        self.events = events
    }
}
