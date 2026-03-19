import SwiftUI

struct PlayerAvatar: View {
    let emoji: String
    let color: Color
    var size: CGFloat = 44

    var body: some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.3))
                .overlay {
                    Circle()
                        .strokeBorder(color, lineWidth: 2)
                }
            Text(emoji)
                .font(.system(size: size * 0.45))
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}
