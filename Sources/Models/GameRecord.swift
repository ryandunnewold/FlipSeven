import Foundation

/// A completed game saved to history.
struct GameRecord: Identifiable, Codable {
    let id: UUID
    let date: Date
    let roundsPlayed: Int
    let players: [PlayerSnapshot]
    /// Score events from that game, for the per-game activity view.
    let events: [ScoreEvent]
    /// Which edition of Flip 7 was played. `nil` for games saved before
    /// variant support landed — treat as `.standard` when reading.
    let variant: GameVariant?
    /// Number of sudden-death tiebreaker rounds played at the end of the game.
    /// `nil` or 0 means no tiebreaker was needed.
    let suddenDeathRounds: Int?

    var winner: PlayerSnapshot? { players.first { $0.isWinner } }
    var resolvedVariant: GameVariant { variant ?? .standard }
    var hadSuddenDeath: Bool { (suddenDeathRounds ?? 0) > 0 }

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

    init(
        roundsPlayed: Int,
        players: [PlayerSnapshot],
        events: [ScoreEvent],
        variant: GameVariant = .standard,
        suddenDeathRounds: Int = 0
    ) {
        self.id = UUID()
        self.date = Date()
        self.roundsPlayed = roundsPlayed
        self.players = players
        self.events = events
        self.variant = variant
        self.suddenDeathRounds = suddenDeathRounds > 0 ? suddenDeathRounds : nil
    }
}
