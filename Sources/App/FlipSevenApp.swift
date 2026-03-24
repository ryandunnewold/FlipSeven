import SwiftUI

@main
struct FlipSevenApp: App {
    @State private var viewModel: GameViewModel

    init() {
        let args = ProcessInfo.processInfo.arguments
        if args.contains("-SNAPSHOT_DEMO") {
            Self.seedDemoData()
        }
        if args.contains("-SNAPSHOT_WINNER") {
            Self.seedWinnerData()
        }
        _viewModel = State(initialValue: GameViewModel())
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(viewModel)
        }
    }

    private static func seedDemoData() {
        let defaults = UserDefaults.standard

        // Demo players
        let alice = Player(name: "Alice", emoji: "🦊", colorIndex: 0)
        let bob = Player(name: "Bob", emoji: "🐸", colorIndex: 1)
        let cara = Player(name: "Cara", emoji: "🦋", colorIndex: 2)
        let dave = Player(name: "Dave", emoji: "🐻", colorIndex: 3)

        var aliceWithStats = alice
        aliceWithStats.gamesPlayed = 5
        aliceWithStats.gamesWon = 3
        aliceWithStats.totalRoundWins = 12
        aliceWithStats.totalBusts = 4

        var bobWithStats = bob
        bobWithStats.gamesPlayed = 5
        bobWithStats.gamesWon = 1
        bobWithStats.totalRoundWins = 8
        bobWithStats.totalBusts = 7

        var caraWithStats = cara
        caraWithStats.gamesPlayed = 4
        caraWithStats.gamesWon = 1
        caraWithStats.totalRoundWins = 6
        caraWithStats.totalBusts = 3

        var daveWithStats = dave
        daveWithStats.gamesPlayed = 3
        daveWithStats.gamesWon = 0
        daveWithStats.totalRoundWins = 4
        daveWithStats.totalBusts = 5

        let roster = [aliceWithStats, bobWithStats, caraWithStats, daveWithStats]
        if let data = try? JSONEncoder().encode(roster) {
            defaults.set(data, forKey: "flip7.roster")
        }

        // Demo game history
        let historyRecord = GameRecord(
            roundsPlayed: 6,
            players: [
                GameRecord.PlayerSnapshot(id: alice.id, name: "Alice", emoji: "🦊", colorIndex: 0, finalScore: 215, roundWins: 3, busts: 1, isWinner: true),
                GameRecord.PlayerSnapshot(id: bob.id, name: "Bob", emoji: "🐸", colorIndex: 1, finalScore: 178, roundWins: 2, busts: 2, isWinner: false),
                GameRecord.PlayerSnapshot(id: cara.id, name: "Cara", emoji: "🦋", colorIndex: 2, finalScore: 142, roundWins: 1, busts: 1, isWinner: false),
            ],
            events: []
        )
        if let data = try? JSONEncoder().encode([historyRecord]) {
            defaults.set(data, forKey: "flip7.gameHistory")
        }

        // Demo active game (mid-game, round 3)
        let gpAlice = GamePlayer(player: alice, score: 87, roundWins: 2, busts: 0)
        let gpBob = GamePlayer(player: bob, score: 64, roundWins: 1, busts: 1)
        let gpCara = GamePlayer(player: cara, score: 52, roundWins: 0, busts: 1)

        struct ActiveGameState: Codable {
            let gamePlayers: [GamePlayer]
            let roundNum: Int
            let currentRoundSelections: [UUID: RoundSelection]
            let roundHistory: [[UUID: RoundSelection]]
            let scoreEvents: [ScoreEvent]
        }

        let activeState = ActiveGameState(
            gamePlayers: [gpAlice, gpBob, gpCara],
            roundNum: 3,
            currentRoundSelections: [:],
            roundHistory: [
                [alice.id: RoundSelection(isConfirmed: true, appliedPoints: 42, appliedWin: true),
                 bob.id: RoundSelection(isConfirmed: true, appliedPoints: 38, appliedWin: false),
                 cara.id: RoundSelection(isConfirmed: true, appliedPoints: 27, appliedWin: false)],
                [alice.id: RoundSelection(isConfirmed: true, appliedPoints: 45, appliedWin: true),
                 bob.id: RoundSelection(isConfirmed: true, appliedPoints: 0, appliedBust: true),
                 cara.id: RoundSelection(isConfirmed: true, appliedPoints: 25, appliedWin: false)],
            ],
            scoreEvents: [
                ScoreEvent(round: 1, playerId: alice.id, playerName: "Alice", playerEmoji: "🦊", playerColorIndex: 0, points: 42, isRoundWin: true, isBust: false),
                ScoreEvent(round: 1, playerId: bob.id, playerName: "Bob", playerEmoji: "🐸", playerColorIndex: 1, points: 38, isRoundWin: false, isBust: false),
                ScoreEvent(round: 1, playerId: cara.id, playerName: "Cara", playerEmoji: "🦋", playerColorIndex: 2, points: 27, isRoundWin: false, isBust: false),
                ScoreEvent(round: 2, playerId: alice.id, playerName: "Alice", playerEmoji: "🦊", playerColorIndex: 0, points: 45, isRoundWin: true, isBust: false),
                ScoreEvent(round: 2, playerId: bob.id, playerName: "Bob", playerEmoji: "🐸", playerColorIndex: 1, points: 0, isRoundWin: false, isBust: true),
                ScoreEvent(round: 2, playerId: cara.id, playerName: "Cara", playerEmoji: "🦋", playerColorIndex: 2, points: 25, isRoundWin: false, isBust: false),
            ]
        )

        if let data = try? JSONEncoder().encode(activeState) {
            defaults.set(data, forKey: "flip7.activeGame")
        }
    }

    private static func seedWinnerData() {
        let defaults = UserDefaults.standard

        let alice = Player(name: "Alice", emoji: "🦊", colorIndex: 0)
        let bob = Player(name: "Bob", emoji: "🐸", colorIndex: 1)
        let cara = Player(name: "Cara", emoji: "🦋", colorIndex: 2)

        var aliceWithStats = alice
        aliceWithStats.gamesPlayed = 5
        aliceWithStats.gamesWon = 3
        aliceWithStats.totalRoundWins = 12
        aliceWithStats.totalBusts = 4

        var bobWithStats = bob
        bobWithStats.gamesPlayed = 5
        bobWithStats.gamesWon = 1
        bobWithStats.totalRoundWins = 8
        bobWithStats.totalBusts = 7

        var caraWithStats = cara
        caraWithStats.gamesPlayed = 4
        caraWithStats.gamesWon = 1
        caraWithStats.totalRoundWins = 6
        caraWithStats.totalBusts = 3

        let roster = [aliceWithStats, bobWithStats, caraWithStats]
        if let data = try? JSONEncoder().encode(roster) {
            defaults.set(data, forKey: "flip7.roster")
        }

        // Winner game state: Alice just crossed 200 in round 6
        let gpAlice = GamePlayer(player: alice, score: 215, roundWins: 4, busts: 1)
        let gpBob = GamePlayer(player: bob, score: 178, roundWins: 2, busts: 2)
        let gpCara = GamePlayer(player: cara, score: 142, roundWins: 1, busts: 1)

        struct ActiveGameState: Codable {
            let gamePlayers: [GamePlayer]
            let roundNum: Int
            let currentRoundSelections: [UUID: RoundSelection]
            let roundHistory: [[UUID: RoundSelection]]
            let scoreEvents: [ScoreEvent]
        }

        let activeState = ActiveGameState(
            gamePlayers: [gpAlice, gpBob, gpCara],
            roundNum: 7,
            currentRoundSelections: [:],
            roundHistory: [],
            scoreEvents: []
        )

        if let data = try? JSONEncoder().encode(activeState) {
            defaults.set(data, forKey: "flip7.activeGame")
        }
    }
}
