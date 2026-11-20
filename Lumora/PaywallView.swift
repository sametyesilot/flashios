import SwiftUI
import StoreKit

/// Aylık abonelik ekranı. Apple 3.1.2 kurallarına uygun: fiyat net, otomatik yenileme açıklaması,
/// Geri Yükle, Kullanım Koşulları ve Gizlilik Politikası linkleri, her zaman kapatılabilir.
struct PaywallView: View {
    let theme: Theme
    let onFinish: (_ purchased: Bool) -> Void

    @Environment(StoreManager.self) private var store
    @Environment(\.openURL) private var openURL
    @State private var glow = false

    private var price: String {
        #if DEBUG
        if store.product == nil, let i = ProcessInfo.processInfo.arguments.firstIndex(of: "-demoPrice"),
           i + 1 < ProcessInfo.processInfo.arguments.count {
            return ProcessInfo.processInfo.arguments[i + 1]
        }
        #endif
        return store.product?.displayPrice ?? "—"
    }

    var body: some View {
        ZStack {
            LinearGradient(colors: [theme.top, Color.black], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            RadialGradient(colors: [theme.glow.opacity(0.45), .clear], center: .init(x: 0.5, y: 0.22),
                           startRadius: 0, endRadius: 360)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button { onFinish(false) } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.7))
                            .frame(width: 36, height: 36)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                    .accessibilityLabel(Text("Close"))
                    Spacer()
                }
                .padding(.top, 8)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {
                        heroOrb.padding(.top, 12)

                        VStack(spacing: 10) {
                            Text(verbatim: "Lumora Pro")
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                            Text("Unlimited light. Every theme.")
                                .font(.system(size: 17, weight: .medium, design: .rounded))
                                .foregroundStyle(.white.opacity(0.65))
                                .multilineTextAlignment(.center)
                        }

                        VStack(alignment: .leading, spacing: 16) {
                            feature("bolt.fill", Text("Unlimited flashlight use"))
                            feature("paintpalette.fill", Text("All 5 premium themes"))
                            feature("xmark.circle.fill", Text("Cancel anytime"))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(20)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .strokeBorder(.white.opacity(0.1), lineWidth: 0.8))

                        priceCard
                    }
                    .padding(.bottom, 16)
                }

                VStack(spacing: 12) {
                    if store.productLoadFailed && store.product == nil {
                        Text("Couldn't load the subscription. Check your connection and try again.")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                    Button {
                        Task {
                            let ok = await store.purchase()
                            if ok { onFinish(true) }
                        }
                    } label: {
                        ZStack {
                            if store.isPurchasing {
                                ProgressView().tint(.black)
                            } else {
                                Text("Continue")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                            }
                        }
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 58)
                        .background(
                            LinearGradient(colors: [theme.core, theme.glow], startPoint: .top, endPoint: .bottom),
                            in: RoundedRectangle(cornerRadius: 18, style: .continuous)
                        )
                        .shadow(color: theme.glow.opacity(0.5), radius: 18, y: 8)
                    }
                    .buttonStyle(PressScaleStyle())
                    .disabled(store.isPurchasing || store.product == nil)
                    .opacity(price == "—" ? 0.6 : 1)

                    if price != "—" {
                    Text("Auto-renews for \(price) per month until canceled. Cancel anytime in Settings.")
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.45))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                    }

                    HStack(spacing: 14) {
                        Button("Restore Purchases") {
                            Task {
                                await store.restore()
                                if store.isPro { onFinish(true) }
                            }
                        }
                        Text(verbatim: "·")
                        Button("Terms of Use") { openURL(AppConfig.termsURL) }
                        Text(verbatim: "·")
                        Button("Privacy Policy") { openURL(AppConfig.privacyURL) }
                    }
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white.opacity(0.6))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                }
                .padding(.bottom, 8)
            }
            .padding(.horizontal, 24)
            .frame(maxWidth: 520)
        }
        .task { await store.loadProduct() }
        .alert(Text(verbatim: "Lumora"), isPresented: Binding(
            get: { store.message != nil },
            set: { if !$0 { store.message = nil } })
        ) {
            Button("OK") { store.message = nil }
        } message: {
            Text(store.message ?? "")
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true)) { glow = true }
        }
        .preferredColorScheme(.dark)
    }

    private var heroOrb: some View {
        ZStack {
            Circle().fill(theme.glow).frame(width: 150, height: 150).blur(radius: 50)
                .opacity(glow ? 0.9 : 0.55)
            Circle()
                .fill(RadialGradient(colors: [theme.core, theme.glow], center: .center, startRadius: 0, endRadius: 60))
                .frame(width: 104, height: 104)
                .shadow(color: theme.glow, radius: 30)
            Image(systemName: "flashlight.on.fill")
                .font(.system(size: 40, weight: .regular))
                .foregroundStyle(theme.bottom.opacity(0.85))
        }
        .frame(height: 170)
    }

    private var priceCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Monthly")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                Text(verbatim: "Lumora Pro")
                    .font(.system(size: 13))
                    .foregroundStyle(.white.opacity(0.5))
            }
            Spacer()
            if store.product != nil || price != "—" {
                Text("\(price) / month")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            } else if store.productLoadFailed {
                Button("Try Again") { Task { await store.loadProduct() } }
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(theme.glow)
            } else {
                ProgressView().tint(.white)
            }
        }
        .padding(20)
        .background(theme.glow.opacity(0.12), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous)
            .strokeBorder(theme.glow.opacity(0.8), lineWidth: 1.4))
    }

    private func feature(_ symbol: String, _ title: Text) -> some View {
        HStack(spacing: 14) {
            Image(systemName: symbol)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(theme.glow)
                .frame(width: 30, height: 30)
                .background(theme.glow.opacity(0.14), in: Circle())
            title
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.9))
        }
    }
}
