import SwiftUI

/// Uygulamanın tek ekranı.
struct ContentView: View {
    @Environment(TorchController.self) private var torch
    @Environment(StoreManager.self) private var store

    @AppStorage("themeID") private var themeID = Theme.obsidian.id
    @State private var showPaywall = false
    @State private var turnOnAfterPurchase = false
    @State private var toggleTick = 0
    @State private var showManageSubscription = false

    private var theme: Theme {
        let t = Theme.with(id: themeID)
        return (t.isPremium && !store.isPro) ? .obsidian : t
    }

    var body: some View {
        GeometryReader { geo in
            let diameter = min(max(min(geo.size.width, geo.size.height) * 0.62, 200), 320)

            ZStack {
                background(size: geo.size)

                VStack(spacing: 0) {
                    header
                        .padding(.top, 8)

                    Spacer(minLength: 24)

                    PowerButton(isOn: torch.isOn, theme: theme, diameter: diameter, action: toggle)
                        .disabled(!torch.isAvailable)

                    statusText
                        .padding(.top, diameter * 0.16)

                    Spacer(minLength: 24)

                    ThemePicker(selectedID: theme.id, isPro: store.isPro) { picked in
                        if picked.isPremium && !store.isPro {
                            turnOnAfterPurchase = false
                            showPaywall = true
                        } else {
                            withAnimation(.smooth(duration: 0.5)) { themeID = picked.id }
                        }
                    }
                    .padding(.bottom, 12)
                }
                .padding(.horizontal, 24)
            }
        }
        .sensoryFeedback(.impact(weight: .medium), trigger: toggleTick)
        #if DEBUG
        .onAppear {
            // Ekran görüntüsü için demo modu (yalnızca Debug derlemede).
            let args = ProcessInfo.processInfo.arguments
            if args.contains("-demoOn") { torch.set(true) }
            if args.contains("-showPaywall") { showPaywall = true }
            if args.contains("-resetFree") { FreeUsage.reset() }
        }
        #endif
        .manageSubscriptionsSheet(isPresented: $showManageSubscription)
        .fullScreenCover(isPresented: $showPaywall) {
            PaywallView(theme: theme) { purchased in
                showPaywall = false
                if purchased && turnOnAfterPurchase { torch.set(true); toggleTick += 1 }
            }
        }
    }

    // MARK: - Pieces

    private func background(size: CGSize) -> some View {
        ZStack {
            LinearGradient(colors: [theme.top, theme.bottom], startPoint: .top, endPoint: .bottom)
            RadialGradient(colors: [theme.glow.opacity(0.55), theme.glow.opacity(0.12), .clear],
                           center: .center,
                           startRadius: 0,
                           endRadius: max(size.width, size.height) * 0.75)
                .opacity(torch.isOn ? 1 : 0)
            // İnce gren dokusu premium his verir.
            NoiseOverlay().opacity(0.05).blendMode(.overlay)
        }
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 0.6), value: torch.isOn)
        .animation(.smooth(duration: 0.6), value: theme.id)
    }

    private var header: some View {
        HStack {
            Text(verbatim: "LUMORA")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .tracking(6)
                .foregroundStyle(.white.opacity(0.55))
            Spacer()
            Button {
                if store.isPro { showManageSubscription = true }
                else { turnOnAfterPurchase = false; showPaywall = true }
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: store.isPro ? "checkmark.seal.fill" : "sparkles")
                    Text(verbatim: "PRO")
                }
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .tracking(1.5)
                .foregroundStyle(store.isPro ? theme.glow : .white)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(.ultraThinMaterial, in: Capsule())
                .overlay(Capsule().strokeBorder(.white.opacity(0.15), lineWidth: 0.8))
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text(verbatim: "Lumora Pro"))
        }
    }

    @ViewBuilder
    private var statusText: some View {
        if !torch.isAvailable {
            Text("Flashlight isn't available on this device.")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.6))
                .multilineTextAlignment(.center)
        } else {
            Text(torch.isOn ? "Tap to turn off" : "Tap to turn on")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(torch.isOn ? 0.85 : 0.5))
                .contentTransition(.opacity)
                .animation(.easeInOut(duration: 0.3), value: torch.isOn)
        }
    }

    // MARK: - Logic

    private func toggle() {
        // Kapatmak her zaman serbest.
        if torch.isOn {
            torch.set(false)
            toggleTick += 1
            return
        }
        // Açmak: Pro ise sınırsız, değilse yalnızca ücretsiz hak kadar.
        if store.isPro || FreeUsage.hasFreeTurnOnLeft {
            if torch.set(true) {
                if !store.isPro { FreeUsage.recordTurnOn() }
                toggleTick += 1
            }
        } else {
            turnOnAfterPurchase = true
            showPaywall = true
        }
    }
}

/// Çok hafif, statik gren dokusu.
private struct NoiseOverlay: View {
    var body: some View {
        Canvas { context, size in
            var rng = SeededRandom(seed: 42)
            for _ in 0..<Int(size.width * size.height / 90) {
                let x = Double(rng.next() % UInt64(max(size.width, 1)))
                let y = Double(rng.next() % UInt64(max(size.height, 1)))
                let a = Double(rng.next() % 100) / 100
                context.fill(Path(CGRect(x: x, y: y, width: 1, height: 1)),
                             with: .color(.white.opacity(a)))
            }
        }
        .allowsHitTesting(false)
        .drawingGroup()
    }
}

private struct SeededRandom {
    var state: UInt64
    init(seed: UInt64) { state = seed }
    mutating func next() -> UInt64 {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return state >> 33
    }
}

#Preview {
    ContentView()
        .environment(TorchController())
        .environment(StoreManager())
}
