import SwiftUI

private struct Particle {
    var x: Double
    var y: Double
    var color: Color
    var rotation: Double
    var scale: Double
    var speed: Double
    var drift: Double
}

struct ConfettiOverlay: View {
    let winner: GamePlayer
    let players: [GamePlayer]

    @State private var particles: [Particle] = []
    @State private var cardAppeared = false

    private let colors: [Color] = [
        .flipPink, .flipPurple, .flipBlue, .flipGreen,
        Color(hex: "FFD700"), Color(hex: "FF8A5C"), Color(hex: "C084FC")
    ]

    var body: some View {
        ZStack {
            // Dim background
            Color.black.opacity(0.65)
                .ignoresSafeArea()

            // Confetti layer (behind card)
            TimelineView(.animation) { timeline in
                Canvas { context, size in
                    let t = timeline.date.timeIntervalSinceReferenceDate
                    for particle in particles {
                        let y = (particle.y + particle.speed * t)
                            .truncatingRemainder(dividingBy: size.height + 20) - 10
                        let x = particle.x + sin(t * particle.drift) * 30
                        let rotation = Angle(degrees: particle.rotation + t * 90)

                        let rect = CGRect(
                            x: x - 5 * particle.scale,
                            y: y,
                            width: 10 * particle.scale,
                            height: 6 * particle.scale
                        )

                        var path = Path(rect)
                        path = path.applying(
                            CGAffineTransform(translationX: -rect.midX, y: -rect.midY)
                                .concatenating(CGAffineTransform(rotationAngle: rotation.radians))
                                .concatenating(CGAffineTransform(translationX: rect.midX, y: rect.midY))
                        )
                        context.fill(path, with: .color(particle.color.opacity(0.85)))
                    }
                }
            }
            .ignoresSafeArea()
            .allowsHitTesting(false)

            // Winner celebration card
            VStack(spacing: 0) {
                // Trophy + winner name header
                VStack(spacing: 8) {
                    Text("🏆")
                        .font(.system(size: 56))

                    Text("WINNER!")
                        .font(.system(size: 32, weight: .black, design: .rounded))
                        .foregroundStyle(LinearGradient.flipWinner)

                    HStack(spacing: 8) {
                        Text(winner.emoji)
                            .font(.system(size: 28))
                        Text(winner.name)
                            .font(.flipHeadline())
                            .foregroundStyle(.white)
                    }
                }
                .padding(.top, 28)
                .padding(.horizontal, 24)
                .padding(.bottom, 20)

                Divider()
                    .background(Color.white.opacity(0.2))

                // Final scores
                VStack(spacing: 0) {
                    Text("FINAL SCORES")
                        .font(.flipCaption())
                        .foregroundStyle(.white.opacity(0.5))
                        .kerning(2)
                        .padding(.top, 16)
                        .padding(.bottom, 12)

                    ForEach(Array(players.enumerated()), id: \.element.id) { index, gp in
                        HStack(spacing: 10) {
                            Text(gp.id == winner.id ? "🥇" : (index == 1 ? "🥈" : (index == 2 ? "🥉" : "  ")))
                                .font(.system(size: 18))

                            Text(gp.emoji)
                                .font(.system(size: 18))

                            Text(gp.name)
                                .font(.flipBody())
                                .foregroundStyle(gp.id == winner.id ? Color(hex: "FFD700") : .white)
                                .fontWeight(gp.id == winner.id ? .bold : .semibold)

                            Spacer()

                            Text("\(gp.score)")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundStyle(gp.id == winner.id ? Color(hex: "FFD700") : .white.opacity(0.8))

                            Text("pts")
                                .font(.flipCaption())
                                .foregroundStyle(.white.opacity(0.45))
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(
                            gp.id == winner.id
                                ? Color(hex: "FFD700").opacity(0.08)
                                : Color.clear
                        )
                    }
                }
                .padding(.bottom, 24)
            }
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28))
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .strokeBorder(Color(hex: "FFD700").opacity(0.35), lineWidth: 1.5)
            )
            .padding(.horizontal, 28)
            .scaleEffect(cardAppeared ? 1 : 0.75)
            .opacity(cardAppeared ? 1 : 0)
        }
        .onAppear {
            particles = (0..<80).map { _ in
                Particle(
                    x: Double.random(in: 0...400),
                    y: Double.random(in: -800...0),
                    color: colors.randomElement()!,
                    rotation: Double.random(in: 0...360),
                    scale: Double.random(in: 0.8...1.5),
                    speed: Double.random(in: 80...160),
                    drift: Double.random(in: 0.5...2.0)
                )
            }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                cardAppeared = true
            }
        }
    }
}
