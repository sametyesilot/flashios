import SwiftUI

/// Alttaki 5 tema seçici.
struct ThemePicker: View {
    let selectedID: String
    let isPro: Bool
    let onPick: (Theme) -> Void

    var body: some View {
        VStack(spacing: 14) {
            HStack(spacing: 18) {
                ForEach(Theme.all) { theme in
                    let selected = theme.id == selectedID
                    let locked = theme.isPremium && !isPro
                    Button { onPick(theme) } label: {
                        ZStack {
                            Circle()
                                .fill(RadialGradient(colors: [theme.core, theme.glow, theme.bottom],
                                                     center: .center, startRadius: 0, endRadius: 22))
                                .frame(width: 34, height: 34)
                                .opacity(locked ? 0.55 : 1)
                            Circle()
                                .strokeBorder(.white.opacity(selected ? 0.9 : 0.12), lineWidth: selected ? 1.6 : 0.8)
                                .frame(width: 44, height: 44)
                            if locked {
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundStyle(.white)
                                    .shadow(color: .black.opacity(0.6), radius: 3)
                            }
                        }
                        .frame(width: 44, height: 44)
                        .contentShape(Circle())
                    }
                    .buttonStyle(PressScaleStyle())
                    .accessibilityLabel(Text(verbatim: theme.name))
                    .accessibilityAddTraits(selected ? .isSelected : [])
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial, in: Capsule())
            .overlay(Capsule().strokeBorder(.white.opacity(0.1), lineWidth: 0.8))

            Text(verbatim: Theme.with(id: selectedID).name.uppercased())
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .tracking(4)
                .foregroundStyle(.white.opacity(0.45))
                .contentTransition(.opacity)
                .animation(.easeInOut, value: selectedID)
        }
    }
}
