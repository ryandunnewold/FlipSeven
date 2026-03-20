import SwiftUI

enum Tab: String, CaseIterable {
    case score = "Score"
    case players = "Players"
    case feed = "Feed"
    case rules = "Rules"

    var icon: String {
        switch self {
        case .score:   return "star.fill"
        case .players: return "person.3.fill"
        case .feed:    return "list.bullet.rectangle.portrait.fill"
        case .rules:   return "book.fill"
        }
    }
}

struct TabPicker: View {
    @Binding var selection: Tab
    @Namespace private var namespace

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.flipSnap) {
                        selection = tab
                    }
                } label: {
                    VStack(spacing: 3) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 15, weight: .semibold))
                        Text(tab.rawValue)
                            .font(.system(size: 10, weight: .semibold, design: .rounded))
                    }
                    .foregroundStyle(selection == tab ? .black : .white.opacity(0.7))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background {
                        if selection == tab {
                            Capsule()
                                .fill(.white)
                                .matchedGeometryEffect(id: "tab-indicator", in: namespace)
                        }
                    }
                }
                .buttonStyle(.plain)
                .accessibilityLabel(tab.rawValue)
                .accessibilityAddTraits(selection == tab ? .isSelected : [])
            }
        }
        .padding(4)
        .background {
            Capsule()
                .fill(Color.white.opacity(0.15))
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Game tabs")
    }
}
