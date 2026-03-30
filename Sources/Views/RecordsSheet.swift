import SwiftUI

struct RecordsSheet: View {
    @Environment(GameViewModel.self) private var vm
    @Environment(\.dismiss) private var dismiss

    enum RecordsView: String, CaseIterable {
        case stats = "Stats"
        case history = "History"
    }

    @State private var activeView: RecordsView = .stats

    private var sortedPlayers: [Player] {
        vm.roster
            .filter { $0.gamesPlayed > 0 }
            .sorted {
                if $0.gamesWon != $1.gamesWon { return $0.gamesWon > $1.gamesWon }
                return $0.gamesPlayed > $1.gamesPlayed
            }
    }

    var body: some View {
        ZStack {
            LinearGradient.flipBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // ── Header ───────────────────────────────────────────────
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Records")
                            .font(.flipHeadline())
                            .foregroundStyle(.white)
                        Text("Lifetime stats & game history")
                            .font(.flipCaption())
                            .foregroundStyle(.white.opacity(0.5))
                    }
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.white.opacity(0.55))
                    }
                }
                .padding(.horizontal)
                .padding(.top, 20)
                .padding(.bottom, 14)

                // ── Picker ───────────────────────────────────────────────
                Picker("View", selection: $activeView) {
                    ForEach(RecordsView.allCases, id: \.self) { v in
                        Text(v.rawValue).tag(v)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.bottom, 16)

                // ── Content ──────────────────────────────────────────────
                if activeView == .stats {
                    statsView
                } else {
                    historyView
                }
            }
        }
    }

    // MARK: - Stats

    @ViewBuilder
    private var statsView: some View {
        if sortedPlayers.isEmpty {
            emptyState(icon: "chart.bar.xaxis", message: "No records yet",
                       detail: "Finish a game to see stats here.")
        } else {
            HStack {
                Spacer()
                statHeader("GP")
                statHeader("W")
                statHeader("L")
                statHeader("RW")
                statHeader("B")
            }
            .padding(.horizontal)
            .padding(.bottom, 6)

            ScrollView {
                VStack(spacing: 10) {
                    ForEach(Array(sortedPlayers.enumerated()), id: \.element.id) { rank, player in
                        statsRow(player: player, rank: rank + 1)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
        }
    }

    // MARK: - History

    @ViewBuilder
    private var historyView: some View {
        if vm.gameHistory.isEmpty {
            emptyState(icon: "clock.arrow.circlepath", message: "No games yet",
                       detail: "Completed games will appear here.")
        } else {
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(vm.gameHistory) { record in
                        historyCard(record)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
        }
    }

    @ViewBuilder
    private func historyCard(_ record: GameRecord) -> some View {
        GlassCard {
            VStack(spacing: 10) {
                // Date + rounds
                HStack {
                    Text(record.date, style: .date)
                        .font(.flipCaption())
                        .foregroundStyle(.white.opacity(0.5))
                    Spacer()
                    Text("\(record.roundsPlayed) rounds")
                        .font(.flipCaption())
                        .foregroundStyle(.white.opacity(0.4))
                }

                Divider().overlay(Color.white.opacity(0.12))

                // Player results, sorted by final score desc
                VStack(spacing: 6) {
                    ForEach(record.players) { snap in
                        HStack(spacing: 10) {
                            let color = Player.themeColors[snap.colorIndex % Player.themeColors.count]
                            PlayerAvatar(emoji: snap.emoji, color: color, size: 30)

                            Text(snap.name)
                                .font(.flipCaption())
                                .foregroundStyle(.white)
                                .lineLimit(1)

                            if snap.isWinner {
                                Image(systemName: "trophy.fill")
                                    .font(.system(size: 11))
                                    .foregroundStyle(Color(hex: "FFD700"))
                            }

                            Spacer()

                            Text("\(snap.finalScore) pts")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundStyle(snap.isWinner ? Color(hex: "FFD700") : color)
                        }
                    }
                }
            }
            .padding(14)
        }
    }

    // MARK: - Helpers

    @ViewBuilder
    private func emptyState(icon: String, message: String, detail: String) -> some View {
        Spacer()
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 44))
                .foregroundStyle(.white.opacity(0.2))
            Text(message)
                .font(.flipBody())
                .foregroundStyle(.white.opacity(0.4))
            Text(detail)
                .font(.flipCaption())
                .foregroundStyle(.white.opacity(0.3))
        }
        Spacer()
    }

    @ViewBuilder
    private func statsRow(player: Player, rank: Int) -> some View {
        GlassCard {
            HStack(spacing: 12) {
                Text("#\(rank)")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.35))
                    .frame(width: 28, alignment: .leading)

                PlayerAvatar(emoji: player.emoji, color: player.themeColor, size: 40)

                Text(player.name)
                    .font(.flipBody())
                    .foregroundStyle(.white)
                    .lineLimit(1)

                Spacer()

                statCell("\(player.gamesPlayed)", color: .white.opacity(0.6))
                statCell("\(player.gamesWon)",    color: Color(hex: "FFD700"))
                statCell("\(player.gamesLost)",   color: .white.opacity(0.45))
                statCell("\(player.totalRoundWins)", color: Color.flipPink)
                statCell("\(player.totalBusts)",  color: .red.opacity(0.75))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
        }
    }

    @ViewBuilder
    private func statHeader(_ label: String) -> some View {
        Text(label)
            .font(.system(size: 11, weight: .semibold, design: .rounded))
            .foregroundStyle(.white.opacity(0.35))
            .tracking(1.2)
            .frame(width: 38, alignment: .center)
    }

    @ViewBuilder
    private func statCell(_ value: String, color: Color) -> some View {
        Text(value)
            .font(.system(size: 15, weight: .bold, design: .rounded))
            .foregroundStyle(color)
            .frame(width: 38, alignment: .center)
    }
}
