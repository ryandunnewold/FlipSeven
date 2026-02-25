import SwiftUI

struct ScoringSheet: View {
    let gamePlayer: GamePlayer
    let onConfirm: (Int, Bool, Bool, RoundSelection) -> Void
    let onSaveDraft: (RoundSelection) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var selectedRegular: Set<Int>
    @State private var selectedModifiers: Set<Int>
    @State private var hasDoubler: Bool
    @State private var manualInput: String
    @State private var useManual: Bool
    @FocusState private var manualFocused: Bool
    /// Set to true when the user presses Confirm or Bust so onDisappear skips the draft save.
    @State private var wasConfirmed: Bool = false

    private let regularCols  = Array(repeating: GridItem(.flexible(), spacing: 8), count: 5)
    private let modifierCols = Array(repeating: GridItem(.flexible(), spacing: 8), count: 5)
    private let modifierValues = [2, 4, 6, 8, 10]

    private let winnerBonus = 15

    // MARK: - Init

    init(
        gamePlayer: GamePlayer,
        initialSelection: RoundSelection? = nil,
        onConfirm: @escaping (Int, Bool, Bool, RoundSelection) -> Void,
        onSaveDraft: @escaping (RoundSelection) -> Void
    ) {
        self.gamePlayer = gamePlayer
        self.onConfirm = onConfirm
        self.onSaveDraft = onSaveDraft

        let sel = initialSelection ?? RoundSelection()
        _selectedRegular  = State(initialValue: sel.selectedRegular)
        _selectedModifiers = State(initialValue: sel.selectedModifiers)
        _hasDoubler       = State(initialValue: sel.hasDoubler)
        _manualInput      = State(initialValue: sel.manualInput)
        _useManual        = State(initialValue: sel.useManual)
    }

    // MARK: - Computed

    var regularCount: Int  { selectedRegular.count }
    var isWinner: Bool     { regularCount == 7 }
    var totalSelected: Int { selectedRegular.count + selectedModifiers.count }

    var regularPts:  Int { selectedRegular.reduce(0, +) }
    var modifierPts: Int { selectedModifiers.reduce(0, +) }
    // 2× applies to card values only, then modifiers and winner bonus are added after
    var pointsFromCards: Int {
        let doubled = hasDoubler ? regularPts * 2 : regularPts
        return doubled + modifierPts + (isWinner ? winnerBonus : 0)
    }

    var effectivePoints: Int {
        useManual ? (Int(manualInput) ?? 0) : pointsFromCards
    }

    var isConfirmDisabled: Bool {
        useManual ? manualInput.isEmpty : totalSelected == 0
    }

    var currentSelection: RoundSelection {
        RoundSelection(
            selectedRegular: selectedRegular,
            selectedModifiers: selectedModifiers,
            hasDoubler: hasDoubler,
            useManual: useManual,
            manualInput: manualInput
        )
    }

    // Builds e.g. "22 × 2 + 6 mod + 15 bonus = 63 pts"
    var tallyText: Text {
        var parts: [String] = []
        if totalSelected > 0 {
            parts.append(hasDoubler ? "\(regularPts) × 2" : "\(regularPts)")
        }
        if modifierPts > 0 { parts.append("+\(modifierPts) mod") }
        if isWinner        { parts.append("+\(winnerBonus) bonus") }
        let expr = parts.joined(separator: " ")

        if expr.isEmpty { return Text("") }
        return Text("\(expr) = ") + Text("**\(pointsFromCards) pts**")
    }

    var body: some View {
        ZStack {
            LinearGradient.flipBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // ── Header ───────────────────────────────────────────────
                HStack {
                    PlayerAvatar(emoji: gamePlayer.emoji, color: gamePlayer.themeColor, size: 40)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(gamePlayer.name)
                            .font(.flipHeadline())
                            .foregroundStyle(.white)
                        Text("Select cards scored this round")
                            .font(.flipCaption())
                            .foregroundStyle(.white.opacity(0.55))
                    }
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.white.opacity(0.55))
                    }
                }
                .padding(.horizontal)
                .padding(.top, 20)
                .padding(.bottom, 12)

                // ── Winner badge ─────────────────────────────────────────
                if isWinner {
                    HStack(spacing: 8) {
                        Image(systemName: "trophy.fill")
                        Text("Round Winner!")
                        Image(systemName: "trophy.fill")
                    }
                    .font(.flipBody())
                    .foregroundStyle(.black)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(LinearGradient.flipWinner)
                    .clipShape(Capsule())
                    .transition(.scale.combined(with: .opacity))
                    .padding(.bottom, 8)
                }

                // ── Card grids (scrollable) ───────────────────────────────
                if !useManual {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 14) {

                            // Number cards 0–12
                            sectionLabel("NUMBER CARDS")

                            LazyVGrid(columns: regularCols, spacing: 8) {
                                ForEach(0...12, id: \.self) { n in
                                    cardChip(
                                        label: "\(n)",
                                        isSelected: selectedRegular.contains(n),
                                        selectedColor: gamePlayer.themeColor,
                                        idleColor: Color.white.opacity(0.12),
                                        idleBorder: Color.white.opacity(0.28)
                                    ) {
                                        withAnimation(.flipBounce) {
                                            selectedRegular.formSymmetricDifference([n])
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)

                            // Modifier cards +2 … +12
                            sectionLabel("MODIFIER CARDS")

                            LazyVGrid(columns: modifierCols, spacing: 8) {
                                ForEach(modifierValues, id: \.self) { v in
                                    cardChip(
                                        label: "+\(v)",
                                        isSelected: selectedModifiers.contains(v),
                                        selectedColor: Color(hex: "E8B84B"),
                                        idleColor: Color.flipPink.opacity(0.10),
                                        idleBorder: Color.flipPink.opacity(0.35)
                                    ) {
                                        withAnimation(.flipBounce) {
                                            selectedModifiers.formSymmetricDifference([v])
                                        }
                                    }
                                }
                                cardChip(
                                    label: "2×",
                                    isSelected: hasDoubler,
                                    selectedColor: Color(hex: "FF4E50"),
                                    idleColor: Color(hex: "FF4E50").opacity(0.10),
                                    idleBorder: Color(hex: "FF4E50").opacity(0.40)
                                ) {
                                    withAnimation(.flipBounce) { hasDoubler.toggle() }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 12)
                        }
                        .padding(.top, 4)
                    }
                }

                // ── Manual toggle / input ────────────────────────────────
                Button {
                    withAnimation {
                        useManual.toggle()
                        selectedRegular.removeAll()
                        selectedModifiers.removeAll()
                        hasDoubler = false
                        manualInput = ""
                    }
                } label: {
                    Text(useManual ? "Use card grid" : "Enter manually")
                        .font(.flipCaption())
                        .foregroundStyle(.white.opacity(0.65))
                }
                .padding(.top, 10)
                .padding(.bottom, 6)

                if useManual {
                    TextField("Points", text: $manualInput)
                        .keyboardType(.numberPad)
                        .focused($manualFocused)
                        .font(.flipScore())
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal)
                        .onAppear { manualFocused = true }
                }

                // ── Tally ────────────────────────────────────────────────
                if !useManual && (totalSelected > 0 || hasDoubler) {
                    tallyText
                        .font(.flipBody())
                        .foregroundStyle(.white.opacity(0.85))
                        .padding(.vertical, 6)
                }

                Spacer(minLength: 8)

                // ── Action buttons ───────────────────────────────────────
                HStack(spacing: 12) {
                    Button {
                        wasConfirmed = true
                        onConfirm(0, false, true, currentSelection)
                    } label: {
                        Text("Bust 💥")
                            .font(.flipBody())
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.red.opacity(0.35))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .buttonStyle(.plain)

                    Button {
                        wasConfirmed = true
                        onConfirm(effectivePoints, isWinner, false, currentSelection)
                    } label: {
                        Text("Confirm")
                            .font(.flipBody())
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(LinearGradient.flipPrimary)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .buttonStyle(.plain)
                    .disabled(isConfirmDisabled)
                }
                .padding(.horizontal)
                .padding(.bottom, 28)
                .padding(.top, 8)
            }
        }
        .animation(.flipBounce, value: isWinner)
        .onDisappear {
            // Save card picks as a draft if the user didn't press Confirm/Bust.
            // This covers both the X button and swipe-to-dismiss.
            if !wasConfirmed {
                onSaveDraft(currentSelection)
            }
        }
    }

    // ── Helpers ──────────────────────────────────────────────────────────

    @ViewBuilder
    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .semibold, design: .rounded))
            .foregroundStyle(.white.opacity(0.4))
            .tracking(1.8)
            .padding(.horizontal)
    }

    @ViewBuilder
    private func cardChip(
        label: String,
        isSelected: Bool,
        selectedColor: Color,
        idleColor: Color,
        idleBorder: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            ZStack {
                // Corner pips (top-left, bottom-right rotated)
                VStack {
                    HStack {
                        Text(label)
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                        Spacer()
                    }
                    Spacer()
                    HStack {
                        Spacer()
                        Text(label)
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .rotationEffect(.degrees(180))
                    }
                }
                .padding(5)
                .opacity(0.6)

                // Center value
                Text(label)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
            }
            .foregroundStyle(isSelected ? .black : .white)
            .frame(maxWidth: .infinity)
            .aspectRatio(0.65, contentMode: .fit)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? selectedColor : idleColor)
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(
                                isSelected ? selectedColor : idleBorder,
                                lineWidth: 1.5
                            )
                    }
            }
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.04 : 1.0)
        .animation(.flipBounce, value: isSelected)
    }
}
