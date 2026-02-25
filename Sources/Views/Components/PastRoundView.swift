import SwiftUI

struct PastRoundView: View {
    let roundNum: Int
    let selections: [UUID: RoundSelection]
    let gamePlayers: [GamePlayer]

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(sortedPlayers) { gp in
                    pastRoundCard(gp: gp, selection: selections[gp.id])
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 20)
        }
    }

    // Sort by points earned this round (busts last)
    private var sortedPlayers: [GamePlayer] {
        gamePlayers.sorted { a, b in
            let selA = selections[a.id]
            let selB = selections[b.id]
            let bustA = selA?.appliedBust ?? false
            let bustB = selB?.appliedBust ?? false
            if bustA != bustB { return !bustA }
            return (selA?.appliedPoints ?? 0) > (selB?.appliedPoints ?? 0)
        }
    }

    @ViewBuilder
    private func pastRoundCard(gp: GamePlayer, selection: RoundSelection?) -> some View {
        GlassCard {
            HStack(spacing: 12) {
                PlayerAvatar(emoji: gp.emoji, color: gp.themeColor, size: 40)

                VStack(alignment: .leading, spacing: 3) {
                    Text(gp.name)
                        .font(.flipBody())
                        .foregroundStyle(.white)

                    if let sel = selection {
                        if sel.appliedBust {
                            Text("Bust 💥")
                                .font(.flipCaption())
                                .foregroundStyle(Color.red.opacity(0.85))
                        } else {
                            HStack(spacing: 6) {
                                Text("+\(sel.appliedPoints) pts")
                                    .font(.flipCaption())
                                    .foregroundStyle(.white.opacity(0.65))
                                if sel.appliedWin {
                                    Text("Round Winner 🏆")
                                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                                        .foregroundStyle(Color(hex: "FFD700"))
                                }
                            }
                        }
                    } else {
                        Text("No score recorded")
                            .font(.flipCaption())
                            .foregroundStyle(.white.opacity(0.35))
                    }
                }

                Spacer()

                // Points badge
                if let sel = selection {
                    if sel.appliedBust {
                        Text("—")
                            .font(.flipScore())
                            .foregroundStyle(Color.red.opacity(0.7))
                    } else {
                        Text("+\(sel.appliedPoints)")
                            .font(.flipScore())
                            .foregroundStyle(gp.themeColor)
                    }
                }
            }
            .padding(14)
        }
    }
}
