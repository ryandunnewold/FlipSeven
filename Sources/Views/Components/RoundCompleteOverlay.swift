import SwiftUI

struct RoundCompleteOverlay: View {
    let roundNum: Int
    let onDismiss: () -> Void

    @State private var appeared = false
    @State private var leaving = false

    var visible: Bool { appeared && !leaving }

    var body: some View {
        ZStack {
            Color.black.opacity(visible ? 0.55 : 0)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.25), value: visible)

            VStack(spacing: 6) {
                checkmark
                roundLabel
                completeLabel
            }
            .padding(36)
            .background(overlayBackground)
            .scaleEffect(visible ? 1.0 : 0.85)
            .opacity(visible ? 1 : 0)
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: visible)
        }
        .onAppear {
            withAnimation { appeared = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                withAnimation(.easeIn(duration: 0.2)) { leaving = true }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                onDismiss()
            }
        }
    }

    private var checkmark: some View {
        Text("✓")
            .font(.system(size: 44, weight: .black, design: .rounded))
            .foregroundStyle(LinearGradient.flipPrimary)
            .scaleEffect(visible ? 1.0 : 0.3)
            .opacity(visible ? 1 : 0)
            .animation(.spring(response: 0.38, dampingFraction: 0.55), value: visible)
    }

    private var roundLabel: some View {
        Text("ROUND \(roundNum)")
            .font(.system(size: 13, weight: .bold, design: .rounded))
            .foregroundStyle(.white.opacity(0.6))
            .tracking(3)
            .offset(y: visible ? 0 : 12)
            .opacity(visible ? 1 : 0)
            .animation(.spring(response: 0.42, dampingFraction: 0.7).delay(0.06), value: visible)
    }

    private var completeLabel: some View {
        Text("Complete!")
            .font(.system(size: 34, weight: .black, design: .rounded))
            .foregroundStyle(.white)
            .offset(y: visible ? 0 : 16)
            .opacity(visible ? 1 : 0)
            .animation(.spring(response: 0.42, dampingFraction: 0.65).delay(0.10), value: visible)
    }

    private var overlayBackground: some View {
        RoundedRectangle(cornerRadius: 28)
            .fill(.ultraThinMaterial)
            .overlay {
                RoundedRectangle(cornerRadius: 28)
                    .strokeBorder(Color.white.opacity(0.15), lineWidth: 1)
            }
    }
}
