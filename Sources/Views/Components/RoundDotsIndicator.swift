import SwiftUI

struct RoundDotsIndicator: View {
    let current: Int
    let max: Int = 8

    var body: some View {
        HStack(spacing: 8) {
            ForEach(1...max, id: \.self) { round in
                Circle()
                    .fill(dotColor(for: round))
                    .frame(width: dotSize(for: round), height: dotSize(for: round))
                    .scaleEffect(round == current ? 1.3 : 1.0)
                    .animation(.flipBounce, value: current)
            }
        }
    }

    private func dotColor(for round: Int) -> Color {
        if round < current { return .flipPink }
        if round == current { return .white }
        return .white.opacity(0.25)
    }

    private func dotSize(for round: Int) -> CGFloat {
        round == current ? 12 : 8
    }
}
