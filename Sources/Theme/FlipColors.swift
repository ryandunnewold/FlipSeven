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

    static let flipPink   = Color(hex: "FF6B9D")
    static let flipPurple = Color(hex: "9B59B6")
    static let flipBlue   = Color(hex: "3498DB")
    static let flipGreen  = Color(hex: "2ECC71")

    static let flipBg1 = Color(hex: "1a0533")
    static let flipBg2 = Color(hex: "2d1b69")
    static let flipBg3 = Color(hex: "11998e")

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
        colors: [.flipPink, .flipPurple],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let flipTitle = LinearGradient(
        colors: [.flipPink, Color(hex: "FFD700")],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let flipWinner = LinearGradient(
        colors: [Color(hex: "FFD700"), Color(hex: "FFA500")],
        startPoint: .leading,
        endPoint: .trailing
    )
}
