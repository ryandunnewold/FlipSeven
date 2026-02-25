import SwiftUI

private struct RulePill: View {
    let icon: String
    let title: String
    let detail: String

    var body: some View {
        GlassCard {
            HStack(alignment: .top, spacing: 12) {
                Text(icon)
                    .font(.title2)
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.flipBody())
                        .foregroundStyle(.white)
                    Text(detail)
                        .font(.flipCaption())
                        .foregroundStyle(.white.opacity(0.7))
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity)
            .padding(14)
        }
    }
}

struct RulesTab: View {
    private let rules: [(String, String, String)] = [
        ("🎯", "Goal", "Be the first player to reach 200 points to win the game."),
        ("🃏", "Cards", "Cards are numbered 0–12. The deck has 12 twelves, 11 elevens, 10 tens — all the way down to 2 twos, 1 one, and 1 zero. Higher cards are more common, so the risk of busting grows as you keep flipping."),
        ("⚡️", "Your Turn", "Flip cards one at a time. Stop any time to bank your points, or keep going for more."),
        ("💥", "Busting", "If you flip a number card that you've already drawn this hand, you bust — you score nothing and take a loss for the round."),
        ("🏆", "Seven Cards", "Flip exactly 7 cards without busting to win the round. You score all 7 card values plus a +15 bonus."),
        ("🧊", "Freeze", "An action card. Play it on yourself or any active player — their turn ends immediately and they bank whatever they've flipped so far."),
        ("3️⃣", "Draw Three", "An action card. Play it on yourself or any active player — they must flip 3 more cards before they can stop, whether they like it or not."),
        ("🍀", "Second Chance", "An action card. If you would bust on your next flip, this card saves you — discard it to avoid the bust.")
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(rules, id: \.1) { rule in
                    RulePill(icon: rule.0, title: rule.1, detail: rule.2)
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
        }
    }
}
