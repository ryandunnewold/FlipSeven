import SwiftUI

struct PastRoundView: View {
    let roundNum: Int
    let selections: [UUID: RoundSelection]
    let gamePlayers: [GamePlayer]
    /// Non-nil when editing is supported. Called with the tapped player.
    var onEditPlayer: ((GamePlayer) -> Void)? = nil

    @State private var isEditing = false

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(sortedPlayers) { gp in
                    pastRoundCard(gp: gp, selection: selections[gp.id])
                        .onTapGesture {
                            guard isEditing else { return }
                            onEditPlayer?(gp)
                        }
                        .overlay(alignment: .topTrailing) {
                            if isEditing {
                                Image(systemName: "pencil.circle.fill")
                                    .font(.system(size: 18))
                                    .foregroundStyle(Color.flipPink)
                                    .padding(10)
                            }
                        }
                }

                if onEditPlayer != nil {
                    editRoundButton
                        .padding(.top, 4)
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 20)
        }
        .onChange(of: roundNum) { _, _ in
            isEditing = false
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
        .opacity(isEditing ? 0.85 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isEditing)
    }

    private var editRoundButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) { isEditing.toggle() }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: isEditing ? "checkmark" : "pencil")
                    .font(.system(size: 13, weight: .semibold))
                Text(isEditing ? "Done Editing" : "Edit Round")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(isEditing ? Color.white : Color.flipPink)
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .fill(isEditing
                          ? Color.white.opacity(0.12)
                          : Color.flipPink.opacity(0.15))
                    .overlay {
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(
                                isEditing ? Color.white.opacity(0.2) : Color.flipPink.opacity(0.5),
                                lineWidth: 1
                            )
                    }
            }
        }
        .buttonStyle(.plain)
    }
}
