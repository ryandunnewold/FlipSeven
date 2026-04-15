import SwiftUI

struct ActivityFeedTab: View {
    @Environment(GameViewModel.self) private var vm

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                if vm.gameHistory.isEmpty {
                    emptyState
                } else {
                    ForEach(vm.gameHistory) { record in
                        gameRecordRow(record)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 20)
        }
    }

    @ViewBuilder
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 44))
                .foregroundStyle(.white.opacity(0.2))
            Text("No games yet")
                .font(.flipBody())
                .foregroundStyle(.white.opacity(0.4))
            Text("Completed games will appear here.")
                .font(.flipCaption())
                .foregroundStyle(.white.opacity(0.3))
                .multilineTextAlignment(.center)
        }
        .padding(.top, 60)
    }

    @ViewBuilder
    private func gameRecordRow(_ record: GameRecord) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(record.date, style: .date)
                        .font(.flipCaption())
                        .foregroundStyle(.white.opacity(0.5))
                    Spacer()
                    Text("\(record.roundsPlayed) rounds")
                        .font(.flipCaption())
                        .foregroundStyle(.white.opacity(0.4))
                }

                ForEach(record.players) { player in
                    playerResultRow(player)
                }
            }
            .padding(14)
        }
    }

    @ViewBuilder
    private func playerResultRow(_ player: GameRecord.PlayerSnapshot) -> some View {
        let color = Player.themeColors[player.colorIndex % Player.themeColors.count]

        HStack(spacing: 10) {
            PlayerAvatar(emoji: player.emoji, color: color, size: 32)

            Text(player.name)
                .font(.flipBody())
                .foregroundStyle(.white)

            if player.isWinner {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(Color(hex: "FFD700"))
            }

            Spacer()

            Text("\(player.finalScore)")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(player.isWinner ? Color(hex: "FFD700") : .white.opacity(0.7))
        }
    }
}
