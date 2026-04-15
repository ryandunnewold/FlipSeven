import SwiftUI

struct SettingsTab: View {
    @Environment(GameViewModel.self) private var vm
    @Environment(\.openURL) private var openURL
    @State private var showEndConfirm: Bool = false
    @State private var editingPlayerId: UUID?
    @State private var editName: String = ""
    @State private var showDeleteConfirm: Bool = false
    @State private var deletePlayerId: UUID?

    private let feedbackURL = URL(string: "https://mr-manager-gold.vercel.app/feedback/cmm1a6467000004l1rypht0hj")!

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                sectionHeader("PLAYERS")

                ForEach(vm.roster) { player in
                    playerRow(player)
                }

                if vm.hasActiveGame {
                    sectionHeader("GAME")

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
                    .confirmationDialog("End the current game?",
                                        isPresented: $showEndConfirm,
                                        titleVisibility: .visible) {
                        Button("End Game", role: .destructive) {
                            Haptics.notification(.warning)
                            vm.endGame()
                        }
                        Button("Cancel", role: .cancel) {}
                    }
                }

                Button {
                    openURL(feedbackURL)
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "bubble.left.fill")
                            .font(.system(size: 11))
                        Text("Send Feedback")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                    }
                    .foregroundStyle(.white.opacity(0.35))
                }
                .buttonStyle(.plain)
                .padding(.top, 20)
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 20)
        }
        .confirmationDialog("Delete this player?",
                            isPresented: $showDeleteConfirm,
                            titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                if let id = deletePlayerId {
                    vm.removeFromRoster(id: id)
                }
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    @ViewBuilder
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 11, weight: .semibold, design: .rounded))
            .foregroundStyle(.white.opacity(0.4))
            .tracking(1.8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 8)
    }

    @ViewBuilder
    private func playerRow(_ player: Player) -> some View {
        let isEditing = editingPlayerId == player.id

        GlassCard {
            HStack(spacing: 12) {
                PlayerAvatar(emoji: player.emoji, color: player.themeColor, size: 40)

                if isEditing {
                    TextField("Name", text: $editName)
                        .font(.flipBody())
                        .foregroundStyle(.white)
                        .textFieldStyle(.plain)
                        .onSubmit {
                            vm.updatePlayerName(id: player.id, name: editName)
                            editingPlayerId = nil
                        }
                } else {
                    Text(player.name)
                        .font(.flipBody())
                        .foregroundStyle(.white)
                }

                Spacer()

                if isEditing {
                    Button {
                        vm.updatePlayerName(id: player.id, name: editName)
                        editingPlayerId = nil
                    } label: {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(Color.flipGreen)
                    }
                    .buttonStyle(.plain)
                } else {
                    Button {
                        editName = player.name
                        editingPlayerId = player.id
                    } label: {
                        Image(systemName: "pencil")
                            .font(.system(size: 14))
                            .foregroundStyle(.white.opacity(0.4))
                    }
                    .buttonStyle(.plain)

                    Button {
                        deletePlayerId = player.id
                        showDeleteConfirm = true
                    } label: {
                        Image(systemName: "trash")
                            .font(.system(size: 14))
                            .foregroundStyle(.red.opacity(0.6))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(14)
        }
    }
}
