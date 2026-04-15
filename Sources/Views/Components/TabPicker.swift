import SwiftUI

enum Tab: String, CaseIterable {
    case score = "Score"
    case history = "History"
    case newGame = "New Game"
    case rules = "Rules"
    case settings = "Settings"

    var icon: String {
        switch self {
        case .score:    return "star.fill"
        case .history:  return "list.bullet.rectangle.portrait.fill"
        case .newGame:  return "plus.circle.fill"
        case .rules:    return "book.fill"
        case .settings: return "gearshape.fill"
        }
    }
}

private struct TabButton: View {
    let tab: Tab
    let isSelected: Bool
    let namespace: Namespace.ID
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 3) {
                Image(systemName: tab.icon)
                    .font(.system(size: 15, weight: .semibold))
                Text(tab.rawValue)
                    .font(.system(size: 9, weight: .semibold, design: .rounded))
                    .lineLimit(1)
            }
            .foregroundStyle(isSelected ? .black : .white.opacity(0.7))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background {
                if isSelected {
                    Capsule()
                        .fill(.white)
                        .matchedGeometryEffect(id: "tab-indicator", in: namespace)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(tab.rawValue)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

struct TabPicker: View {
    @Binding var selection: Tab
    @Namespace private var namespace

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.self) { tab in
                TabButton(
                    tab: tab,
                    isSelected: selection == tab,
                    namespace: namespace
                ) {
                    withAnimation(.flipSnap) {
                        selection = tab
                    }
                }
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
