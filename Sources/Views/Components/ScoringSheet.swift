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
    @State private var isManualOverride: Bool
    @FocusState private var manualFocused: Bool
    /// Set to true when the user presses Confirm so onDisappear skips the draft save.
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
        _selectedRegular   = State(initialValue: sel.selectedRegular)
        _selectedModifiers = State(initialValue: sel.selectedModifiers)
        _hasDoubler        = State(initialValue: sel.hasDoubler)
        _isManualOverride  = State(initialValue: sel.useManual)

        if sel.useManual {
            _manualInput = State(initialValue: sel.manualInput.isEmpty ? "0" : sel.manualInput)
        } else {
            // Compute from existing card selections
            let regular = sel.selectedRegular.reduce(0, +)
            let mods    = sel.selectedModifiers.reduce(0, +)
            let isWin   = sel.selectedRegular.count == 7
            let pts     = (sel.hasDoubler ? regular * 2 : regular) + mods + (isWin ? 15 : 0)
            _manualInput = State(initialValue: "\(pts)")
        }
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
        isManualOverride ? (Int(manualInput) ?? 0) : pointsFromCards
    }

    var isBust: Bool { effectivePoints == 0 }

    var currentSelection: RoundSelection {
        RoundSelection(
            selectedRegular: selectedRegular,
            selectedModifiers: selectedModifiers,
            hasDoubler: hasDoubler,
            useManual: isManualOverride,
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

                // ── Prominent score input ────────────────────────────────
                VStack(spacing: 4) {
                    TextField("0", text: $manualInput)
                        .keyboardType(.numberPad)
                        .focused($manualFocused)
                        .font(.flipScore())
                        .foregroundStyle(isBust ? Color.red.opacity(0.8) : .white)
                        .multilineTextAlignment(.center)
                        .onChange(of: manualInput) { _, newVal in
                            // Keep only digits
                            let filtered = newVal.filter { $0.isNumber }
                            if filtered != newVal { manualInput = filtered }
                        }
                        .onChange(of: manualFocused) { _, focused in
                            if focused { isManualOverride = true }
                        }

                    if isBust {
                        Text("BUST 💥")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.red.opacity(0.8))
                            .tracking(1.4)
                            .transition(.scale.combined(with: .opacity))
                    } else if !isManualOverride && (totalSelected > 0 || hasDoubler) {
                        tallyText
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.6))
                    } else if isManualOverride {
                        Text("manual entry")
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.4))
                    } else {
                        Text("tap cards or edit above")
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.35))
                    }
                }
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity)
                .background(Color.white.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(
                            isBust ? Color.red.opacity(0.4) : gamePlayer.themeColor.opacity(0.3),
                            lineWidth: 1.5
                        )
                }
                .padding(.horizontal)
                .padding(.bottom, 10)
                .onTapGesture {
                    isManualOverride = true
                    manualFocused = true
                }

                // Reset to card calculation link
                if isManualOverride && totalSelected > 0 {
                    Button {
                        withAnimation {
                            isManualOverride = false
                            manualInput = "\(pointsFromCards)"
                        }
                    } label: {
                        Text("Use card total (\(pointsFromCards) pts)")
                            .font(.flipCaption())
                            .foregroundStyle(.white.opacity(0.55))
                    }
                    .padding(.bottom, 6)
                }

                // ── Card grids (scrollable) ───────────────────────────────
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
                                withAnimation(.flipBounce) {
                                    hasDoubler.toggle()
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 12)
                    }
                    .padding(.top, 4)
                }

                Spacer(minLength: 8)

                // ── Confirm button ───────────────────────────────────────
                Button {
                    wasConfirmed = true
                    let pts = effectivePoints
                    let bust = pts == 0
                    onConfirm(pts, isWinner && !bust, bust, currentSelection)
                } label: {
                    HStack(spacing: 8) {
                        if isBust {
                            Text("Confirm Bust 💥")
                        } else {
                            Text("Confirm  \(effectivePoints) pts")
                        }
                    }
                    .font(.flipBody())
                    .foregroundStyle(isBust ? .white : .black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(isBust ? AnyShapeStyle(Color.red.opacity(0.5)) : AnyShapeStyle(LinearGradient.flipPrimary))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .buttonStyle(.plain)
                .animation(.flipBounce, value: isBust)
                .padding(.horizontal)
                .padding(.bottom, 28)
                .padding(.top, 8)
            }
        }
        .animation(.flipBounce, value: isWinner)
        .animation(.easeInOut(duration: 0.2), value: isBust)
        .onChange(of: pointsFromCards) { _, newVal in
            if !isManualOverride {
                manualInput = "\(newVal)"
            }
        }
        .onDisappear {
            if !wasConfirmed {
                onSaveDraft(currentSelection)
            }
        }
    }

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
