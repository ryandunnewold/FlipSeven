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
    @Environment(GameViewModel.self) private var vm

    /// If a game is active, show only that variant's rules. Otherwise show
    /// every variant under its own header so both rule sets are discoverable.
    private var sections: [(variant: GameVariant, entries: [RuleEntry])] {
        if vm.hasActiveGame {
            return [(vm.variant, vm.variant.definition.ruleEntries)]
        }
        return GameVariant.allCases.map { ($0, $0.definition.ruleEntries) }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                ForEach(sections, id: \.variant) { section in
                    VStack(spacing: 12) {
                        sectionHeader(for: section.variant)
                        ForEach(section.entries, id: \.self) { rule in
                            RulePill(icon: rule.icon, title: rule.title, detail: rule.detail)
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
    }

    @ViewBuilder
    private func sectionHeader(for v: GameVariant) -> some View {
        // Only render a header when multiple sections are shown (no active game).
        if !vm.hasActiveGame {
            HStack(spacing: 8) {
                Capsule()
                    .fill(v.accentColor)
                    .frame(width: 4, height: 18)
                Text(v.displayName.uppercased())
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .tracking(1.4)
                Spacer()
            }
            .padding(.top, 4)
        }
    }
}
