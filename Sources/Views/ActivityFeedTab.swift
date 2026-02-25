import SwiftUI

struct ActivityFeedTab: View {
    @Environment(GameViewModel.self) private var vm

    /// Events grouped by round, newest round first.
    private var groupedEvents: [(round: Int, events: [ScoreEvent])] {
        let rounds = Set(vm.scoreEvents.map { $0.round }).sorted(by: >)
        return rounds.map { round in
            let events = vm.scoreEvents
                .filter { $0.round == round }
                .sorted { $0.date > $1.date }
            return (round: round, events: events)
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if vm.scoreEvents.isEmpty {
                    emptyState
                } else {
                    ForEach(groupedEvents, id: \.round) { group in
                        roundSection(round: group.round, events: group.events)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 20)
        }
    }

    // MARK: - Sections

    @ViewBuilder
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "list.bullet.rectangle.portrait")
                .font(.system(size: 44))
                .foregroundStyle(.white.opacity(0.2))
            Text("No scores yet")
                .font(.flipBody())
                .foregroundStyle(.white.opacity(0.4))
            Text("Scores will appear here as the game progresses.")
                .font(.flipCaption())
                .foregroundStyle(.white.opacity(0.3))
                .multilineTextAlignment(.center)
        }
        .padding(.top, 60)
    }

    @ViewBuilder
    private func roundSection(round: Int, events: [ScoreEvent]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // Section header
            HStack {
                Text("ROUND \(round)")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.4))
                    .tracking(1.8)
                if round == vm.roundNum {
                    Text("CURRENT")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(LinearGradient.flipPrimary)
                        .clipShape(Capsule())
                }
                Spacer()
            }

            ForEach(events) { event in
                eventRow(event)
            }
        }
    }

    @ViewBuilder
    private func eventRow(_ event: ScoreEvent) -> some View {
        let color = Player.themeColors[event.playerColorIndex % Player.themeColors.count]

        GlassCard {
            HStack(spacing: 12) {
                PlayerAvatar(emoji: event.playerEmoji, color: color, size: 36)

                VStack(alignment: .leading, spacing: 2) {
                    Text(event.playerName)
                        .font(.flipBody())
                        .foregroundStyle(.white)

                    if event.isRoundWin {
                        HStack(spacing: 4) {
                            Image(systemName: "trophy.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(Color(hex: "FFD700"))
                            Text("Round winner")
                                .font(.flipCaption())
                                .foregroundStyle(.white.opacity(0.55))
                        }
                    }
                }

                Spacer()

                if event.isBust {
                    Text("BUST 💥")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(.red.opacity(0.85))
                } else {
                    Text("+\(event.points)")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(color)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
        }
    }
}
