import SwiftUI

struct ScoreTab: View {
    @Environment(GameViewModel.self) private var vm
    @State private var scoringPlayer: GamePlayer? = nil
    @State private var displayedRound: Int = 0
    @State private var showRoundComplete: Bool = false
    @State private var completedRoundNum: Int = 0
    /// Non-nil while editing a past round (0-based index into roundHistory).
    @State private var editingRoundIdx: Int? = nil

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
                            gamePlayers: vm.gamePlayers,
                            onEditPlayer: { gp in
                                editingRoundIdx = idx
                                scoringPlayer = gp
                            }
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
            displayedRound = currentPageIndex
        }
        .sheet(item: $scoringPlayer) { gp in
            let roundIdx = editingRoundIdx
            let initialSelection: RoundSelection? = roundIdx.map { vm.roundHistory[$0][gp.id] }
                ?? vm.currentRoundSelections[gp.id]
            ScoringSheet(
                gamePlayer: gp,
                initialSelection: initialSelection
            ) { points, isWin, isBust, selection in
                if let roundIdx {
                    vm.editHistoryScore(
                        roundIdx: roundIdx,
                        id: gp.id,
                        points: points,
                        isWin: isWin,
                        isBust: isBust,
                        selection: selection
                    )
                    scoringPlayer = nil
                    editingRoundIdx = nil
                } else {
                    vm.scorePlayer(id: gp.id, points: points, isWin: isWin, isBust: isBust, selection: selection)
                    scoringPlayer = nil
                    // Auto-advance to next unscored player, or show round-complete animation then advance
                    Task { @MainActor in
                        try? await Task.sleep(for: .milliseconds(350))
                        if let next = vm.nextUnscoredPlayer() {
                            scoringPlayer = next
                        } else {
                            completedRoundNum = vm.roundNum
                            showRoundComplete = true
                        }
                    }
                }
            } onSaveDraft: { selection in
                if editingRoundIdx == nil {
                    vm.saveDraftSelection(id: gp.id, selection: selection)
                }
            }
            .id(gp.id)
        }
        .overlay {
            if showRoundComplete {
                RoundCompleteOverlay(roundNum: completedRoundNum) {
                    showRoundComplete = false
                    withAnimation(.flipBounce) { vm.nextRound() }
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: showRoundComplete)
    }

    // MARK: - Round tracker header

    private var roundTrackerHeader: some View {
        HStack {
            // Back arrow / past-round hint
            if vm.roundNum > 1 {
                Button {
                    displayedRound = max(0, displayedRound - 1)
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
                    displayedRound = min(currentPageIndex, displayedRound + 1)
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
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 20)
        }
    }
}
