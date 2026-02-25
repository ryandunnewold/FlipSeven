import SwiftUI

struct NewGameSheet: View {
    @Environment(GameViewModel.self) private var vm
    @Environment(\.dismiss) private var dismiss

    @State private var selectedIds: Set<UUID> = []
    @State private var newName: String = ""
    @State private var newEmoji: String = "🦄"
    @State private var showEmojiForNew: Bool = false
    @State private var editingEmojiFor: UUID? = nil
    @FocusState private var nameFocused: Bool

    var canStart: Bool { selectedIds.count >= 2 }

    var body: some View {
        ZStack {
            LinearGradient.flipBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("New Game")
                        .font(.flipHeadline())
                        .foregroundStyle(.white)
                    Spacer()
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
                .padding(.horizontal)
                .padding(.top)
                .padding(.bottom, 4)

                Text("Select 2+ players")
                    .font(.flipCaption())
                    .foregroundStyle(.white.opacity(0.6))
                    .padding(.bottom, 16)

                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(vm.roster) { player in
                            rosterRow(player)
                        }
                        addPlayerCard
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 120)
                }
            }

            // Floating start button
            VStack {
                Spacer()
                Button {
                    vm.startGame(with: Array(selectedIds))
                    dismiss()
                } label: {
                    Text(canStart
                         ? "Start Game — \(selectedIds.count) players"
                         : "Select at least 2 players")
                        .font(.flipBody())
                        .foregroundStyle(canStart ? .black : .white.opacity(0.4))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background {
                            if canStart {
                                LinearGradient.flipPrimary
                            } else {
                                LinearGradient(colors: [Color.white.opacity(0.1)],
                                               startPoint: .leading, endPoint: .trailing)
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(.plain)
                .disabled(!canStart)
                .padding(.horizontal)
                .padding(.bottom, 32)
                .background {
                    LinearGradient(
                        colors: [.clear, Color(hex: "1a0533").opacity(0.97)],
                        startPoint: .top, endPoint: .bottom
                    )
                    .ignoresSafeArea()
                    .frame(height: 140)
                }
            }
        }
    }

    @ViewBuilder
    private func rosterRow(_ player: Player) -> some View {
        GlassCard {
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    Button {
                        withAnimation(.flipBounce) {
                            if selectedIds.contains(player.id) {
                                selectedIds.remove(player.id)
                            } else {
                                selectedIds.insert(player.id)
                            }
                        }
                    } label: {
                        Image(systemName: selectedIds.contains(player.id)
                              ? "checkmark.circle.fill" : "circle")
                            .font(.title3)
                            .foregroundStyle(selectedIds.contains(player.id)
                                             ? Color.flipPink : .white.opacity(0.4))
                    }
                    .buttonStyle(.plain)

                    Button {
                        withAnimation {
                            editingEmojiFor = editingEmojiFor == player.id ? nil : player.id
                        }
                    } label: {
                        Text(player.emoji)
                            .font(.title2)
                            .frame(width: 44, height: 44)
                            .background {
                                Circle()
                                    .fill(player.themeColor.opacity(0.25))
                                    .overlay {
                                        Circle().strokeBorder(player.themeColor, lineWidth: 1.5)
                                    }
                            }
                    }
                    .buttonStyle(.plain)

                    Text(player.name)
                        .font(.flipBody())
                        .foregroundStyle(.white)

                    Spacer()

                    Button {
                        withAnimation(.flipBounce) {
                            selectedIds.remove(player.id)
                            vm.removeFromRoster(id: player.id)
                        }
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.red.opacity(0.7))
                    }
                    .buttonStyle(.plain)
                }
                .padding(14)

                if editingEmojiFor == player.id {
                    Divider()
                        .background(Color.white.opacity(0.1))
                    EmojiPicker(selected: Binding(
                        get: { player.emoji },
                        set: { vm.updatePlayerEmoji(id: player.id, emoji: $0) }
                    ))
                    .padding(12)
                }
            }
        }
    }

    private var addPlayerCard: some View {
        GlassCard {
            VStack(spacing: 10) {
                HStack(spacing: 12) {
                    Button {
                        withAnimation { showEmojiForNew.toggle() }
                    } label: {
                        Text(newEmoji)
                            .font(.title2)
                            .frame(width: 44, height: 44)
                            .background {
                                Circle()
                                    .fill(Color.flipPink.opacity(0.25))
                                    .overlay {
                                        Circle().strokeBorder(Color.flipPink, lineWidth: 1.5)
                                    }
                            }
                    }
                    .buttonStyle(.plain)

                    TextField("New player name", text: $newName)
                        .font(.flipBody())
                        .foregroundStyle(.white)
                        .focused($nameFocused)
                        .onSubmit { addNewPlayer() }

                    Button(action: addNewPlayer) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundStyle(Color.flipPink)
                    }
                    .buttonStyle(.plain)
                    .disabled(newName.trimmingCharacters(in: .whitespaces).isEmpty)
                }

                if showEmojiForNew {
                    Divider().background(Color.white.opacity(0.1))
                    EmojiPicker(selected: $newEmoji)
                        .padding(.top, 4)
                }
            }
            .padding(14)
        }
    }

    private func addNewPlayer() {
        let trimmed = newName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        vm.addToRoster(name: trimmed, emoji: newEmoji)
        if let newest = vm.roster.last {
            selectedIds.insert(newest.id)
        }
        newName = ""
        newEmoji = "🦄"
        showEmojiForNew = false
    }
}
