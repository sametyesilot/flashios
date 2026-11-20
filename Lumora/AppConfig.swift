import Foundation

/// Uygulamanın tüm ayarları tek yerde. Yayına çıkmadan önce sadece burayı düzenle.
enum AppConfig {
    /// App Store Connect'te oluşturacağın aylık aboneliğin Product ID'si.
    static let proMonthlyID = "com.lumora.flashlight.pro.monthly"

    /// Ücretsiz kullanıcının kaç kez ışık açabileceği. 1 = aç → kapat → tekrar açmak için Pro.
    static let freeTurnOns = 1

    /// Gizlilik politikası (GitHub Pages: sametyesilot/flashios reposunun docs klasörü).
    static let privacyURL = URL(string: "https://sametyesilot.github.io/flashios/privacy.html")!

    /// Apple'ın standart kullanım koşulları (EULA). Kendi EULA'n yoksa bu link yeterli.
    static let termsURL = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!
}
