import SwiftUI

/// Which retail edition of Flip 7 is being scored.
/// Different editions ship with different action-card sets and may also override
/// number-card distribution, modifier cards, or the round-winner bonus.
enum GameVariant: String, Codable, CaseIterable, Identifiable, Hashable {
    case standard
    case vengeance

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .standard:  return "Flip 7"
        case .vengeance: return "Flip 7: Vengeance"
        }
    }

    var shortName: String {
        switch self {
        case .standard:  return "Standard"
        case .vengeance: return "Vengeance"
        }
    }

    var accentColor: Color {
        switch self {
        case .standard:  return .flipPink
        case .vengeance: return Color(hex: "FF4E50")
        }
    }

    var definition: VariantDefinition { Self.definitions[self]! }

    private static let definitions: [GameVariant: VariantDefinition] = [
        .standard:  .standard,
        .vengeance: .vengeance
    ]
}

/// One entry on the Rules tab.
struct RuleEntry: Hashable {
    let icon: String
    let title: String
    let detail: String
}

/// Round-winner bonus: awarded when a player flips `requiredUniqueNumberCards`
/// distinct number cards in a single round.
struct BonusSpec: Hashable {
    let points: Int
    let requiredUniqueNumberCards: Int
}

/// Describes one of the variant's action cards (drives the Rules tab; the
/// scoring sheet only needs number cards + modifiers to compute totals).
struct ActionCardSpec: Hashable, Identifiable {
    let icon: String
    let name: String
    let detail: String
    var id: String { name }
}

struct VariantDefinition {
    let variant: GameVariant
    let numberCardValues: [Int]
    let modifierAddValues: [Int]
    let includesDoubler: Bool
    let roundWinnerBonus: BonusSpec
    let actionCards: [ActionCardSpec]
    /// Rules-tab entries shown when this variant is active. Number-card and
    /// bonus rules are included so each variant fully describes its own ruleset.
    let ruleEntries: [RuleEntry]
}

extension VariantDefinition {
    static let standard = VariantDefinition(
        variant: .standard,
        numberCardValues: Array(0...12),
        modifierAddValues: [2, 4, 6, 8, 10],
        includesDoubler: true,
        roundWinnerBonus: BonusSpec(points: 15, requiredUniqueNumberCards: 7),
        actionCards: [
            ActionCardSpec(icon: "🧊", name: "Freeze",
                           detail: "Play on yourself or any active player — their turn ends immediately and they bank whatever they've flipped."),
            ActionCardSpec(icon: "3️⃣", name: "Draw Three",
                           detail: "Play on yourself or any active player — they must flip 3 more cards before they can stop."),
            ActionCardSpec(icon: "🍀", name: "Second Chance",
                           detail: "If you would bust on your next flip, discard this card to avoid the bust.")
        ],
        ruleEntries: [
            RuleEntry(icon: "🎯", title: "Goal",
                      detail: "Be the first player to reach 200 points to win the game."),
            RuleEntry(icon: "🃏", title: "Cards",
                      detail: "Cards are numbered 0–12. The deck has 12 twelves, 11 elevens, 10 tens — all the way down to 2 twos, 1 one, and 1 zero. Higher cards are more common, so the risk of busting grows as you keep flipping."),
            RuleEntry(icon: "⚡️", title: "Your Turn",
                      detail: "Flip cards one at a time. Stop any time to bank your points, or keep going for more."),
            RuleEntry(icon: "💥", title: "Busting",
                      detail: "If you flip a number card that you've already drawn this hand, you bust — you score nothing and take a loss for the round."),
            RuleEntry(icon: "🏆", title: "Seven Cards",
                      detail: "Flip exactly 7 cards without busting to win the round. You score all 7 card values plus a +15 bonus."),
            RuleEntry(icon: "🧊", title: "Freeze",
                      detail: "Action card. Play on yourself or any active player — their turn ends immediately and they bank whatever they've flipped."),
            RuleEntry(icon: "3️⃣", title: "Draw Three",
                      detail: "Action card. Play on yourself or any active player — they must flip 3 more cards before they can stop."),
            RuleEntry(icon: "🍀", title: "Second Chance",
                      detail: "Action card. If you would bust on your next flip, discard this card to avoid the bust.")
        ]
    )

    /// Vengeance edition — modeled from the publicly available Vengeance
    /// rulebook / manufacturer pages. Entries are best-effort and should be
    /// revised once a physical copy is verified. Number cards and modifiers
    /// match the base game; bonus is bumped to +20 and the action-card set
    /// is replaced with the Vengeance lineup.
    static let vengeance = VariantDefinition(
        variant: .vengeance,
        numberCardValues: Array(0...12),
        modifierAddValues: [2, 4, 6, 8, 10],
        includesDoubler: true,
        roundWinnerBonus: BonusSpec(points: 20, requiredUniqueNumberCards: 7),
        actionCards: [
            ActionCardSpec(icon: "🗡️", name: "Vengeance",
                           detail: "When another player would knock you out, you may flip this — the attacker busts instead. Discard after use."),
            ActionCardSpec(icon: "🔄", name: "Swap",
                           detail: "Swap one of your number cards with one in another active player's hand."),
            ActionCardSpec(icon: "🪞", name: "Mirror",
                           detail: "Reflect the next action card played on you back at the player who played it."),
            ActionCardSpec(icon: "🎭", name: "Steal",
                           detail: "Take one action card from another active player's hand."),
            ActionCardSpec(icon: "🍀", name: "Second Chance",
                           detail: "If you would bust on your next flip, discard this card to avoid the bust.")
        ],
        ruleEntries: [
            RuleEntry(icon: "🎯", title: "Goal",
                      detail: "First to 200 points wins — same target as the base game."),
            RuleEntry(icon: "🃏", title: "Cards",
                      detail: "Number cards 0–12 (same distribution as base Flip 7). The action-card lineup is replaced with the Vengeance set."),
            RuleEntry(icon: "⚡️", title: "Your Turn",
                      detail: "Flip cards one at a time. Stop to bank your points or keep going."),
            RuleEntry(icon: "💥", title: "Busting",
                      detail: "Flipping a duplicate number card busts you — score nothing for the round."),
            RuleEntry(icon: "🏆", title: "Seven Cards",
                      detail: "Flip exactly 7 unique number cards without busting to win the round. Vengeance pays a bigger +20 bonus instead of the base +15."),
            RuleEntry(icon: "🗡️", title: "Vengeance",
                      detail: "When another player would knock you out, flip Vengeance — the attacker busts instead. Once-per-card use."),
            RuleEntry(icon: "🔄", title: "Swap",
                      detail: "Swap one of your number cards with one in another active player's hand."),
            RuleEntry(icon: "🪞", title: "Mirror",
                      detail: "Reflect the next action card played on you back at its source."),
            RuleEntry(icon: "🎭", title: "Steal",
                      detail: "Take one action card from another active player."),
            RuleEntry(icon: "🍀", title: "Second Chance",
                      detail: "Avoid a bust on your next flip by discarding this card.")
        ]
    )
}
