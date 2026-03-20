import SwiftUI

struct ContentView: View {
    @Environment(GameViewModel.self) private var vm
    @State private var selectedTab: Tab = .score
    @State private var showNewGameSheet: Bool = false
    @State private var showRecordsSheet: Bool = false

    var body: some View {
        ZStack {
            LinearGradient.flipBackground
                .ignoresSafeArea()

            if vm.hasActiveGame {
                gameView
                    .transition(.opacity)
            } else {
                lobbyView
                    .transition(.opacity)
            }

            if vm.showConfetti, let winner = vm.confirmedWinner {
                ConfettiOverlay(winner: winner, players: vm.sortedGamePlayers)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: vm.hasActiveGame)
        .animation(.easeInOut(duration: 0.3), value: vm.showConfetti)
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showNewGameSheet) {
            NewGameSheet()
                .environment(vm)
        }
        .sheet(isPresented: $showRecordsSheet) {
            RecordsSheet()
                .environment(vm)
        }
    }

    private var lobbyView: some View {
        VStack(spacing: 40) {
            Spacer()

            VStack(spacing: 10) {
                Text("FLIP SEVEN")
                    .font(.flipTitle())
                    .foregroundStyle(LinearGradient.flipTitle)
                Text("First to 200 wins")
                    .font(.flipBody())
                    .foregroundStyle(.white.opacity(0.55))
            }

            Button {
                showNewGameSheet = true
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "play.circle.fill")
                        .font(.title2)
                    Text("New Game")
                        .font(.flipBody())
                }
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(LinearGradient.flipPrimary)
                .clipShape(RoundedRectangle(cornerRadius: 18))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 48)
            .accessibilityLabel("Start a new game")

            Button {
                showRecordsSheet = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "chart.bar.fill")
                    Text("Records")
                        .font(.flipCaption())
                }
                .foregroundStyle(.white.opacity(0.5))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("View player records and game history")

            Spacer()
        }
    }

    private var gameView: some View {
        VStack(spacing: 0) {
            HStack {
                Text("FLIP SEVEN")
                    .font(.flipTitle())
                    .foregroundStyle(LinearGradient.flipTitle)
                Spacer()
                Button {
                    showNewGameSheet = true
                } label: {
                    Image(systemName: "plus.circle")
                        .font(.title3)
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 12)

            TabPicker(selection: $selectedTab)
                .padding(.horizontal, 20)
                .padding(.bottom, 16)

            Group {
                switch selectedTab {
                case .score:
                    ScoreTab()
                case .players:
                    PlayersTab()
                case .feed:
                    ActivityFeedTab()
                case .rules:
                    RulesTab()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
