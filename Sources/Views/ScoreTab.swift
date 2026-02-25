import SwiftUI

struct ScoreTab: View {
    @Environment(GameViewModel.self) private var vm
    @State private var scoringPlayer: GamePlayer? = nil
    @State private var displayedRound: Int = 0

    private var currentPageIndex: Int { vm.roundNum - 1 }

    var body: some View {
        VStack(spacing: 0) {
            // ── Round tracker header ────────────────────────────────────
            roundTrackerHeader
                .padding(.horizontal)
                .padding(.top, 12)
                .padding(.bottom, 6)

            // ── Swipeable round pages ───────────────────────────────────
            TabView(selection: $displayedRound) {
                ForEach(0..<vm.roundNum, id: \.self) { idx in
                    if idx < vm.roundHistory.count {
                        PastRoundView(
                            roundNum: idx + 1,
                            selections: vm.roundHistory[idx],
                            gamePlayers: vm.gamePlayers
                        )
                        .tag(idx)
                    } else {
                        currentRoundPage
                            .tag(idx)
                    }
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .onAppear { displayedRound = currentPageIndex }
        .onChange(of: vm.roundNum) { _, _ in
            withAnimation(.easeInOut(duration: 0.35)) {
                displayedRound = currentPageIndex
            }
        }
        .sheet(item: $scoringPlayer) { gp in
            ScoringSheet(
                gamePlayer: gp,
                initialSelection: vm.currentRoundSelections[gp.id]
            ) { points, isWin, isBust, selection in
                vm.scorePlayer(id: gp.id, points: points, isWin: isWin, isBust: isBust, selection: selection)
                scoringPlayer = nil
                // Auto-advance to next unscored player, or next round if all scored
                Task { @MainActor in
                    try? await Task.sleep(for: .milliseconds(350))
                    if let next = vm.nextUnscoredPlayer() {
                        scoringPlayer = next
                    } else {
                        withAnimation(.flipBounce) { vm.nextRound() }
                    }
                }
            } onSaveDraft: { selection in
                vm.saveDraftSelection(id: gp.id, selection: selection)
            }
        }
    }

    // MARK: - Round tracker header

    private var roundTrackerHeader: some View {
        HStack {
            // Back arrow / past-round hint
            if vm.roundNum > 1 {
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        displayedRound = max(0, displayedRound - 1)
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(displayedRound > 0 ? Color.flipPink : Color.white.opacity(0.2))
                }
                .disabled(displayedRound == 0)
            } else {
                Color.clear.frame(width: 24, height: 24)
            }

            Spacer()

            VStack(spacing: 3) {
                Text("Round \(displayedRound + 1)")
                    .font(.flipHeadline())
                    .foregroundStyle(.white)

                if displayedRound < currentPageIndex {
                    Text("PAST ROUND")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.flipPink)
                        .tracking(1.4)
                }
            }

            Spacer()

            // Forward arrow (back to current)
            if displayedRound < currentPageIndex {
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        displayedRound = min(currentPageIndex, displayedRound + 1)
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.flipPink)
                }
            } else {
                Color.clear.frame(width: 24, height: 24)
            }
        }
    }

    // MARK: - Current round page

    private var currentRoundPage: some View {
        ScrollView {
            VStack(spacing: 16) {
                if let winner = vm.confirmedWinner {
                    GlassCard {
                        HStack(spacing: 10) {
                            Image(systemName: "trophy.fill")
                                .foregroundStyle(Color(hex: "FFD700"))
                            Text("\(winner.name) wins! 🎉")
                                .font(.flipBody())
                                .foregroundStyle(.white)
                            Spacer()
                        }
                        .padding(14)
                    }
                }

                ForEach(vm.sortedGamePlayers) { gp in
                    PlayerScoreCard(
                        gamePlayer: gp,
                        target: vm.target,
                        isScored: vm.currentRoundSelections[gp.id]?.isConfirmed == true
                    ) {
                        scoringPlayer = gp
                    }
                }

                Button {
                    withAnimation(.flipBounce) { vm.nextRound() }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.right.circle.fill")
                        Text("Next Round!")
                    }
                    .font(.flipBody())
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(LinearGradient.flipPrimary)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(.plain)
                .padding(.top, 4)
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 20)
        }
    }
}
