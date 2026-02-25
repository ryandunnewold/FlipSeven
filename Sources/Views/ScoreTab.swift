import SwiftUI

struct ScoreTab: View {
    @Environment(GameViewModel.self) private var vm
    @State private var scoringPlayer: GamePlayer? = nil

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                RoundDotsIndicator(current: vm.roundNum)
                    .padding(.top, 4)

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
        .sheet(item: $scoringPlayer) { gp in
            ScoringSheet(
                gamePlayer: gp,
                initialSelection: vm.currentRoundSelections[gp.id]
            ) { points, isWin, isBust, selection in
                vm.scorePlayer(id: gp.id, points: points, isWin: isWin, isBust: isBust, selection: selection)
                scoringPlayer = nil
            } onSaveDraft: { selection in
                vm.saveDraftSelection(id: gp.id, selection: selection)
            }
        }
    }
}
