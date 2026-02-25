import SwiftUI

struct EmojiPicker: View {
    @Binding var selected: String

    static let emojis: [String] = [
        "🦄", "🐉", "🦊", "🐬", "🦁", "🐺",
        "🦋", "🐙", "🐼", "🦈", "🦅", "🐸",
        "🐯", "🦜", "🦩", "🐻", "🦆", "🐳",
        "🐠", "🐊", "🐝", "🦔", "🦙", "🦘",
        "👾", "🎮", "🃏", "⭐️", "🔥", "💀"
    ]

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 6)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(Self.emojis, id: \.self) { emoji in
                Button {
                    selected = emoji
                } label: {
                    Text(emoji)
                        .font(.title2)
                        .frame(maxWidth: .infinity)
                        .aspectRatio(1, contentMode: .fit)
                        .background {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(selected == emoji
                                      ? Color.white.opacity(0.3)
                                      : Color.white.opacity(0.08))
                                .overlay {
                                    if selected == emoji {
                                        RoundedRectangle(cornerRadius: 8)
                                            .strokeBorder(Color.flipPink, lineWidth: 2)
                                    }
                                }
                        }
                }
                .buttonStyle(.plain)
            }
        }
    }
}
