/// Tracks a player's card picks (and confirmed result) for the current round.
/// Persists across sheet open/close until "Next Round!" is tapped.
struct RoundSelection: Codable {
    var selectedRegular: Set<Int> = []
    var selectedModifiers: Set<Int> = []
    var hasDoubler: Bool = false
    var useManual: Bool = false
    var manualInput: String = ""

    // Whether the player has pressed Confirm/Bust this round
    var isConfirmed: Bool = false

    // What was actually applied to their cumulative score (for undo on re-confirm)
    var appliedPoints: Int = 0
    var appliedWin: Bool = false
    var appliedBust: Bool = false
}
