import SwiftUI

struct ContentView: View {
    @Environment(GameViewModel.self) private var vm
    @State private var selectedTab: Tab = .score
    @State private var showNewGameSheet: Bool = false
    @State private var showRecordsSheet: Bool = false
    @Environment(\.openURL) private var openURL

    private let feedbackURL = URL(string: "https://mr-manager-gold.vercel.app/feedback/cmm1a6467000004l1rypht0hj")!

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
        .onChange(of: selectedTab) { oldTab, newTab in
            switch newTab {
            case .newGame:
                showNewGameSheet = true
                selectedTab = oldTab
            default:
                break
            }
        }
    }

    private var lobbyView: some View {
        VStack(spacing: 40) {
            Spacer()

            VStack(spacing: 10) {
                Text("FLIPPY KEEP SCORE")
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
            .padding(.bottom, 20)
        }
    }

    private var gameView: some View {
        VStack(spacing: 0) {
            Text("FLIPPY KEEP SCORE")
                .font(.flipTitle())
                .foregroundStyle(LinearGradient.flipTitle)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 12)

            Group {
                switch selectedTab {
                case .score:
                    ScoreTab()
                case .history:
                    ActivityFeedTab()
                case .rules:
                    RulesTab()
                case .settings:
                    SettingsTab()
                case .newGame:
                    EmptyView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            TabPicker(selection: $selectedTab)
                .padding(.horizontal, 12)
                .padding(.bottom, 8)
        }
    }
}
