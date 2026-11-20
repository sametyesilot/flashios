import StoreKit
import Observation

/// StoreKit 2 ile aylık Pro aboneliğini yönetir (Apple'ın kendi ödeme sistemi).
@MainActor
@Observable
final class StoreManager {
    private(set) var product: Product?
    private(set) var isPro = false
    private(set) var isPurchasing = false
    private(set) var isLoadingProduct = false
    private(set) var productLoadFailed = false
    var message: String?

    @ObservationIgnored private var updatesTask: Task<Void, Never>?

    init() {
        updatesTask = Task { [weak self] in
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await transaction.finish()
                    await self?.refreshEntitlements()
                }
            }
        }
        Task {
            await loadProduct()
            await refreshEntitlements()
        }
    }

    func loadProduct() async {
        guard product == nil, !isLoadingProduct else { return }
        isLoadingProduct = true
        productLoadFailed = false
        defer { isLoadingProduct = false }
        // Ağ anlık koparsa birkaç kez dene (inceleme ekibinin sandbox ortamı bazen yavaştır).
        for attempt in 0..<3 {
            if let p = try? await Product.products(for: [AppConfig.proMonthlyID]).first {
                product = p
                return
            }
            try? await Task.sleep(for: .seconds(Double(attempt + 1)))
        }
        productLoadFailed = true
    }

    func refreshEntitlements() async {
        var active = false
        for await result in Transaction.currentEntitlements {
            if case .verified(let t) = result,
               t.productID == AppConfig.proMonthlyID,
               t.revocationDate == nil {
                active = true
            }
        }
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-demoPro") { active = true }
        #endif
        isPro = active
    }

    /// Satın alma başarılıysa true döner.
    func purchase() async -> Bool {
        if product == nil { await loadProduct() }
        guard let product else {
            message = String(localized: "Purchase couldn't be completed. Please try again.")
            return false
        }
        isPurchasing = true
        defer { isPurchasing = false }
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if case .verified(let transaction) = verification {
                    await transaction.finish()
                    await refreshEntitlements()
                    return isPro
                }
                message = String(localized: "Purchase couldn't be completed. Please try again.")
                return false
            case .pending, .userCancelled:
                return false
            @unknown default:
                return false
            }
        } catch {
            message = String(localized: "Purchase couldn't be completed. Please try again.")
            return false
        }
    }

    func restore() async {
        isPurchasing = true
        defer { isPurchasing = false }
        try? await AppStore.sync()
        await refreshEntitlements()
        if !isPro { message = String(localized: "No active subscription found.") }
    }
}
