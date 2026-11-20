import SwiftUI

/// Ortadaki büyük, cam efektli güç butonu.
struct PowerButton: View {
    let isOn: Bool
    let theme: Theme
    let diameter: CGFloat
    let action: () -> Void

    @State private var breathe = false

    var body: some View {
        Button(action: action) {
            ZStack {
                // Dış ışık patlaması
                Circle()
                    .fill(theme.glow)
                    .frame(width: diameter * 1.15, height: diameter * 1.15)
                    .blur(radius: diameter * 0.32)
                    .opacity(isOn ? (breathe ? 0.85 : 0.6) : 0)

                // Saat kadranı gibi ince çentik halkası
                TickRing(count: 72, isOn: isOn, color: theme.glow)
                    .frame(width: diameter * 1.12, height: diameter * 1.12)
                    .rotationEffect(.degrees(isOn ? 6 : 0))

                // Cam dış halka
                Circle()
                    .fill(.ultraThinMaterial)
                    .overlay(
                        Circle().strokeBorder(
                            LinearGradient(colors: [.white.opacity(0.4), .white.opacity(0.02), .white.opacity(0.12)],
                                           startPoint: .topLeading, endPoint: .bottomTrailing),
                            lineWidth: 1.2)
                    )
                    .frame(width: diameter, height: diameter)
                    .shadow(color: .black.opacity(0.55), radius: 30, y: 22)

                // İç disk
                Circle()
                    .fill(innerFill)
                    .overlay(
                        Circle().strokeBorder(.white.opacity(isOn ? 0.7 : 0.08), lineWidth: 1)
                    )
                    .overlay(
                        // Üstte cam parlaması
                        Circle()
                            .trim(from: 0.55, to: 0.95)
                            .stroke(.white.opacity(isOn ? 0.0 : 0.18), style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
                            .rotationEffect(.degrees(-15))
                            .padding(6)
                    )
                    .frame(width: diameter * 0.7, height: diameter * 0.7)
                    .shadow(color: isOn ? theme.glow.opacity(0.95) : .clear, radius: diameter * 0.18)

                Image(systemName: isOn ? "flashlight.on.fill" : "flashlight.off.fill")
                    .font(.system(size: diameter * 0.2, weight: .regular))
                    .contentTransition(.symbolEffect(.replace))
                    .foregroundStyle(isOn ? theme.bottom.opacity(0.85) : .white.opacity(0.85))
                    .shadow(color: isOn ? .clear : .white.opacity(0.25), radius: 8)
            }
            .frame(width: diameter * 1.15, height: diameter * 1.15)
            .contentShape(Circle())
            .animation(.spring(response: 0.45, dampingFraction: 0.75), value: isOn)
            .animation(.smooth(duration: 0.6), value: theme.id)
        }
        .buttonStyle(PressScaleStyle())
        .accessibilityLabel(Text("Flashlight"))
        .accessibilityValue(Text(isOn ? "On" : "Off"))
        .onAppear {
            withAnimation(.easeInOut(duration: 2.6).repeatForever(autoreverses: true)) { breathe = true }
        }
    }

    private var innerFill: AnyShapeStyle {
        if isOn {
            AnyShapeStyle(RadialGradient(colors: [theme.core, theme.glow],
                                         center: .center, startRadius: 0, endRadius: diameter * 0.42))
        } else {
            AnyShapeStyle(LinearGradient(colors: [Color(white: 0.17), Color(white: 0.05)],
                                         startPoint: .top, endPoint: .bottom))
        }
    }
}

private struct TickRing: View {
    let count: Int
    let isOn: Bool
    let color: Color

    var body: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius = min(size.width, size.height) / 2
            for i in 0..<count {
                let angle = Double(i) / Double(count) * 2 * .pi
                let isMajor = i % 6 == 0
                let length: CGFloat = isMajor ? 9 : 5
                let outer = CGPoint(x: center.x + cos(angle) * radius, y: center.y + sin(angle) * radius)
                let inner = CGPoint(x: center.x + cos(angle) * (radius - length),
                                    y: center.y + sin(angle) * (radius - length))
                var path = Path()
                path.move(to: inner)
                path.addLine(to: outer)
                context.stroke(path,
                               with: .color(isOn ? color.opacity(isMajor ? 0.9 : 0.5) : .white.opacity(isMajor ? 0.22 : 0.1)),
                               lineWidth: isMajor ? 1.6 : 1)
            }
        }
        .allowsHitTesting(false)
    }
}

struct PressScaleStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
