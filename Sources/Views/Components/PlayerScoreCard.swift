import SwiftUI

struct PlayerScoreCard: View {
    let gamePlayer: GamePlayer
    let target: Int
    let isScored: Bool
    let onScoreTap: () -> Void

    var progress: Double {
        min(Double(gamePlayer.score) / Double(target), 1.0)
    }

    var body: some View {
        Button(action: onScoreTap) {
            GlassCard {
                HStack(spacing: 12) {
                    PlayerAvatar(emoji: gamePlayer.emoji, color: gamePlayer.themeColor, size: 48)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(gamePlayer.name)
                            .font(.flipBody())
                            .foregroundStyle(.white)

                        Text("\(gamePlayer.roundWins)W – \(gamePlayer.busts)L")
                            .font(.flipCaption())
                            .foregroundStyle(.white.opacity(0.6))

                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.white.opacity(0.15))
                                    .frame(height: 6)
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(gamePlayer.themeColor)
                                    .frame(width: geo.size.width * progress, height: 6)
                                    .animation(.flipSnap, value: progress)
                            }
                        }
                        .frame(height: 6)
                    }

                    Spacer()

                    VStack(spacing: 2) {
                        Text("\(gamePlayer.score)")
                            .font(.flipScore())
                            .foregroundStyle(isScored ? .white : gamePlayer.themeColor)

                        if isScored {
                            HStack(spacing: 3) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 10, weight: .bold))
                                Text("scored")
                                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                            }
                            .foregroundStyle(gamePlayer.themeColor)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(isScored
                                  ? gamePlayer.themeColor.opacity(0.35)
                                  : gamePlayer.themeColor.opacity(0.15))
                            .overlay {
                                RoundedRectangle(cornerRadius: 10)
                                    .strokeBorder(
                                        isScored ? gamePlayer.themeColor : gamePlayer.themeColor.opacity(0.4),
                                        lineWidth: isScored ? 2 : 1
                                    )
                            }
                            .shadow(color: isScored ? gamePlayer.themeColor.opacity(0.5) : .clear, radius: 6)
                    }
                    .animation(.flipSnap, value: isScored)
                }
                .padding(14)
            }
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(gamePlayer.name), \(gamePlayer.score) points, \(gamePlayer.roundWins) wins, \(gamePlayer.busts) busts")
        .accessibilityHint(isScored ? "Already scored this round. Tap to edit." : "Tap to score this round.")
    }
}
