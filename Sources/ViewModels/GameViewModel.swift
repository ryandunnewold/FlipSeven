import SwiftUI

@Observable
@MainActor
final class GameViewModel {
    var roster: [Player] = []

    init() {
        if let data = UserDefaults.standard.data(forKey: "flip7.roster"),
           let saved = try? JSONDecoder().decode([Player].self, from: data) {
            roster = saved
        }
        if let data = UserDefaults.standard.data(forKey: historyKey),
           let saved = try? JSONDecoder().decode([GameRecord].self, from: data) {
            gameHistory = saved
        }
        restoreActiveGame()
    }

    private func saveRoster() {
        if let data = try? JSONEncoder().encode(roster) {
            UserDefaults.standard.set(data, forKey: "flip7.roster")
        }
    }

    private func saveHistory() {
        if let data = try? JSONEncoder().encode(gameHistory) {
            UserDefaults.standard.set(data, forKey: historyKey)
        }
    }

    // MARK: - Active game state persistence

    private let activeGameKey = "flip7.activeGame"

    private struct ActiveGameState: Codable {
        let gamePlayers: [GamePlayer]
        let roundNum: Int
        let currentRoundSelections: [UUID: RoundSelection]
        let roundHistory: [[UUID: RoundSelection]]
        let scoreEvents: [ScoreEvent]
    }

    private func saveActiveGame() {
        guard hasActiveGame else {
            UserDefaults.standard.removeObject(forKey: activeGameKey)
            return
        }
        let state = ActiveGameState(
            gamePlayers: gamePlayers,
            roundNum: roundNum,
            currentRoundSelections: currentRoundSelections,
            roundHistory: roundHistory,
            scoreEvents: scoreEvents
        )
        if let data = try? JSONEncoder().encode(state) {
            UserDefaults.standard.set(data, forKey: activeGameKey)
        }
    }

    private func restoreActiveGame() {
        guard let data = UserDefaults.standard.data(forKey: activeGameKey),
              let state = try? JSONDecoder().decode(ActiveGameState.self, from: data) else { return }
        gamePlayers = state.gamePlayers
        roundNum = state.roundNum
        currentRoundSelections = state.currentRoundSelections
        roundHistory = state.roundHistory
        scoreEvents = state.scoreEvents
        hasActiveGame = true

        // In winner snapshot mode, auto-trigger confetti without auto-dismiss
        if ProcessInfo.processInfo.arguments.contains("-SNAPSHOT_WINNER"),
           let winner = gameWinner {
            confirmedWinner = winner
            showConfetti = true
        }
    }

    private func clearActiveGame() {
        UserDefaults.standard.removeObject(forKey: activeGameKey)
    }

    var gamePlayers: [GamePlayer] = []
    var roundNum: Int = 1
    var hasActiveGame: Bool = false
    var showConfetti: Bool = false
    var confirmedWinner: GamePlayer? = nil
    let target: Int = 200

    /// Card picks (and confirmed result) for each player in the current round.
    /// Persists until nextRound() is called.
    var currentRoundSelections: [UUID: RoundSelection] = [:]

    /// Completed round selections, indexed by round (index 0 = round 1).
    var roundHistory: [[UUID: RoundSelection]] = []

    /// Score events for the current active game (activity feed).
    var scoreEvents: [ScoreEvent] = []

    /// All completed games, newest first.
    var gameHistory: [GameRecord] = []

    private let historyKey = "flip7.gameHistory"

    var sortedGamePlayers: [GamePlayer] {
        gamePlayers.sorted { $0.score > $1.score }
    }

    var gameWinner: GamePlayer? {
        gamePlayers.first { $0.score >= target }
    }

    // MARK: - Roster

    func addToRoster(name: String, emoji: String) {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        let colorIndex = roster.count % 4
        roster.append(Player(name: trimmed, emoji: emoji, colorIndex: colorIndex))
        saveRoster()
    }

    func removeFromRoster(id: UUID) {
        roster.removeAll { $0.id == id }
        saveRoster()
    }

    func updatePlayerEmoji(id: UUID, emoji: String) {
        guard let idx = roster.firstIndex(where: { $0.id == id }) else { return }
        roster[idx].emoji = emoji
        saveRoster()
    }

    func updatePlayerName(id: UUID, name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty,
              let idx = roster.firstIndex(where: { $0.id == id }) else { return }
        roster[idx].name = trimmed
        saveRoster()
    }

    // MARK: - Game lifecycle

    func startGame(with playerIds: [UUID]) {
        guard !playerIds.isEmpty else { return }
        gamePlayers = playerIds.compactMap { id in
            roster.first { $0.id == id }.map { GamePlayer(player: $0) }
        }
        roundNum = 1
        hasActiveGame = true
        showConfetti = false
        confirmedWinner = nil
        currentRoundSelections = [:]
        roundHistory = []
        scoreEvents = []
        Haptics.notification(.success)
        saveActiveGame()
    }

    func endGame() {
        let winnerId = gameWinner?.id

        // Save a game record to history
        let snapshots = gamePlayers.map { gp in
            GameRecord.PlayerSnapshot(
                id: gp.id,
                name: gp.name,
                emoji: gp.emoji,
                colorIndex: gp.player.colorIndex,
                finalScore: gp.score,
                roundWins: gp.roundWins,
                busts: gp.busts,
                isWinner: gp.id == winnerId
            )
        }.sorted { $0.finalScore > $1.finalScore }

        let record = GameRecord(roundsPlayed: roundNum, players: snapshots, events: scoreEvents)
        gameHistory.insert(record, at: 0)
        saveHistory()

        // Persist each player's game stats into their lifetime record
        for gp in gamePlayers {
            guard let idx = roster.firstIndex(where: { $0.id == gp.id }) else { continue }
            roster[idx].gamesPlayed += 1
            if gp.id == winnerId {
                roster[idx].gamesWon += 1
            } else {
                roster[idx].gamesLost += 1
            }
            roster[idx].totalRoundWins += gp.roundWins
            roster[idx].totalBusts += gp.busts
        }
        saveRoster()

        hasActiveGame = false
        gamePlayers = []
        roundNum = 1
        currentRoundSelections = [:]
        roundHistory = []
        scoreEvents = []
        clearActiveGame()
    }

    /// Mark all unscored players as busted (0 pts) for the current round.
    func bustUnscoredPlayers() {
        for gp in gamePlayers {
            guard currentRoundSelections[gp.id]?.isConfirmed != true else { continue }
            scorePlayer(id: gp.id, points: 0, isWin: false, isBust: true, selection: RoundSelection())
        }
    }

    func nextRound() {
        if let winner = gameWinner, confirmedWinner == nil {
            confirmedWinner = winner
            triggerConfetti()
        }
        roundHistory.append(currentRoundSelections)
        roundNum += 1
        currentRoundSelections = [:]
        saveActiveGame()
    }

    /// Returns the first game player who has not yet had their score confirmed this round.
    func nextUnscoredPlayer() -> GamePlayer? {
        gamePlayers.first { currentRoundSelections[$0.id]?.isConfirmed != true }
    }

    var allPlayersScored: Bool {
        gamePlayers.allSatisfy { currentRoundSelections[$0.id]?.isConfirmed == true }
    }

    /// Save card picks without applying a score (sheet dismissed without confirming).
    func saveDraftSelection(id: UUID, selection: RoundSelection) {
        // Don't overwrite an already-confirmed entry with a draft
        if let existing = currentRoundSelections[id], existing.isConfirmed { return }
        currentRoundSelections[id] = selection
    }

    /// Edit a score from a completed past round, then recompute all player totals.
    func editHistoryScore(roundIdx: Int, id: UUID, points: Int, isWin: Bool, isBust: Bool, selection: RoundSelection) {
        guard roundIdx < roundHistory.count else { return }
        var sel = selection
        sel.isConfirmed = true
        sel.appliedPoints = isBust ? 0 : points
        sel.appliedWin = isWin && !isBust
        sel.appliedBust = isBust
        roundHistory[roundIdx][id] = sel
        recomputeScores()

        // Refresh activity feed entry for this player/round
        scoreEvents.removeAll { $0.playerId == id && $0.round == roundIdx + 1 }
        if let idx = gamePlayers.firstIndex(where: { $0.id == id }) {
            let gp = gamePlayers[idx]
            scoreEvents.append(ScoreEvent(
                round: roundIdx + 1,
                playerId: id,
                playerName: gp.name,
                playerEmoji: gp.emoji,
                playerColorIndex: gp.player.colorIndex,
                points: isBust ? 0 : points,
                isRoundWin: isWin && !isBust,
                isBust: isBust
            ))
        }
    }

    /// Recompute every player's score / roundWins / busts from the full round history
    /// plus any confirmed current-round scores.
    private func recomputeScores() {
        for i in gamePlayers.indices {
            gamePlayers[i].score = 0
            gamePlayers[i].roundWins = 0
            gamePlayers[i].busts = 0
        }
        for roundSelections in roundHistory {
            for (playerId, sel) in roundSelections {
                guard sel.isConfirmed else { continue }
                guard let idx = gamePlayers.firstIndex(where: { $0.id == playerId }) else { continue }
                if sel.appliedBust {
                    gamePlayers[idx].busts += 1
                } else {
                    gamePlayers[idx].score += sel.appliedPoints
                    if sel.appliedWin { gamePlayers[idx].roundWins += 1 }
                }
            }
        }
        for (playerId, sel) in currentRoundSelections {
            guard sel.isConfirmed else { continue }
            guard let idx = gamePlayers.firstIndex(where: { $0.id == playerId }) else { continue }
            if sel.appliedBust {
                gamePlayers[idx].busts += 1
            } else {
                gamePlayers[idx].score += sel.appliedPoints
                if sel.appliedWin { gamePlayers[idx].roundWins += 1 }
            }
        }
    }

    /// Confirm a player's score for this round. Supports re-confirming (undoes previous
    /// contribution first so the score stays correct).
    func scorePlayer(id: UUID, points: Int, isWin: Bool, isBust: Bool, selection: RoundSelection) {
        guard let idx = gamePlayers.firstIndex(where: { $0.id == id }) else { return }

        // Undo any score already applied this round for this player
        if let existing = currentRoundSelections[id], existing.isConfirmed {
            if existing.appliedBust {
                gamePlayers[idx].busts -= 1
            } else {
                gamePlayers[idx].score -= existing.appliedPoints
                if existing.appliedWin {
                    gamePlayers[idx].roundWins -= 1
                }
            }
        }

        // Apply the new result
        if isBust {
            gamePlayers[idx].busts += 1
        } else {
            gamePlayers[idx].score += points
            if isWin { gamePlayers[idx].roundWins += 1 }
        }

        // Persist the confirmed selection
        var confirmed = selection
        confirmed.isConfirmed = true
        confirmed.appliedPoints = isBust ? 0 : points
        confirmed.appliedWin = isWin && !isBust
        confirmed.appliedBust = isBust
        currentRoundSelections[id] = confirmed

        // Update the activity feed — remove any previous entry for this player this round
        // (handles re-confirms), then append the latest result
        scoreEvents.removeAll { $0.playerId == id && $0.round == roundNum }
        let gp = gamePlayers[idx]
        scoreEvents.append(ScoreEvent(
            round: roundNum,
            playerId: id,
            playerName: gp.name,
            playerEmoji: gp.emoji,
            playerColorIndex: gp.player.colorIndex,
            points: isBust ? 0 : points,
            isRoundWin: isWin && !isBust,
            isBust: isBust
        ))

        Haptics.notification(isBust ? .warning : (isWin ? .success : .success))
        saveActiveGame()
    }

    private func triggerConfetti() {
        showConfetti = true
        Task {
            try? await Task.sleep(for: .seconds(10))
            showConfetti = false
        }
    }
}
