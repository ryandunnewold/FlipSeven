import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: Double(a)/255)
    }

    // Logo-derived accent colors
    static let flipPink   = Color(hex: "FF6B8A")
    static let flipPurple = Color(hex: "8B5CF6")
    static let flipBlue   = Color(hex: "6366F1")
    static let flipGreen  = Color(hex: "4CD964")

    // Logo-derived background: deep navy/indigo
    static let flipBg1 = Color(hex: "0F0A2E")
    static let flipBg2 = Color(hex: "1C1259")
    static let flipBg3 = Color(hex: "2D1B69")

    static let glassWhite  = Color.white.opacity(0.1)
    static let glassBorder = Color.white.opacity(0.2)
}

extension LinearGradient {
    static let flipBackground = LinearGradient(
        colors: [.flipBg1, .flipBg2, .flipBg3],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let flipPrimary = LinearGradient(
        colors: [Color(hex: "4CD964"), Color(hex: "FFD700"), Color(hex: "FF8A5C")],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let flipTitle = LinearGradient(
        colors: [Color(hex: "4CD964"), Color(hex: "FFD700"), Color(hex: "FF8A5C")],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let flipWinner = LinearGradient(
        colors: [Color(hex: "FFD700"), Color(hex: "FF8A5C")],
        startPoint: .leading,
        endPoint: .trailing
    )
}
