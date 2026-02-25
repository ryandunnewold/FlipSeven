import SwiftUI

struct PlayersTab: View {
    @Environment(GameViewModel.self) private var vm
    @State private var showEndConfirm: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(vm.gamePlayers) { gp in
                    GlassCard {
                        HStack(spacing: 12) {
                            PlayerAvatar(emoji: gp.emoji, color: gp.themeColor, size: 48)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(gp.name)
                                    .font(.flipBody())
                                    .foregroundStyle(.white)
                                HStack(spacing: 16) {
                                    Label("\(gp.roundWins)", systemImage: "trophy.fill")
                                        .foregroundStyle(Color(hex: "FFD700"))
                                    Label("\(gp.busts)", systemImage: "xmark.circle.fill")
                                        .foregroundStyle(.red.opacity(0.8))
                                }
                                .font(.flipCaption())
                            }

                            Spacer()

                            Text("\(gp.score)")
                                .font(.flipScore())
                                .foregroundStyle(gp.themeColor)
                        }
                        .padding(14)
                    }
                }

                Button {
                    showEndConfirm = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "stop.circle")
                        Text("End Game")
                    }
                    .font(.flipBody())
                    .foregroundStyle(.white.opacity(0.7))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.white.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(.plain)
                .padding(.top, 8)
                .confirmationDialog("End the current game?",
                                    isPresented: $showEndConfirm,
                                    titleVisibility: .visible) {
                    Button("End Game", role: .destructive) { vm.endGame() }
                    Button("Cancel", role: .cancel) {}
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 20)
        }
    }
}
