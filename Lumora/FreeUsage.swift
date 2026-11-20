import Foundation
import Security

/// Ücretsiz açma hakkını Keychain'de tutar; uygulama silinip yeniden yüklense bile sıfırlanmaz.
enum FreeUsage {
    private static let service = "com.lumora.flashlight.usage"
    private static let account = "turnOnCount"

    private static let defaultsKey = "lumora.turnOnCount"

    /// Keychain ve UserDefaults'tan büyük olanı (biri başarısız olsa bile sayaç kaybolmaz).
    static var turnOnCount: Int {
        max(keychainCount, UserDefaults.standard.integer(forKey: defaultsKey))
    }

    private static var keychainCount: Int {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var item: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess,
              let data = item as? Data,
              let string = String(data: data, encoding: .utf8),
              let value = Int(string) else { return 0 }
        return value
    }

    static var hasFreeTurnOnLeft: Bool { turnOnCount < AppConfig.freeTurnOns }

    static func recordTurnOn() {
        let next = turnOnCount + 1
        UserDefaults.standard.set(next, forKey: defaultsKey)
        let data = Data(String(next).utf8)
        let base: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        let status = SecItemUpdate(base as CFDictionary, [kSecValueData as String: data] as CFDictionary)
        if status == errSecItemNotFound {
            var add = base
            add[kSecValueData as String] = data
            add[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
            SecItemAdd(add as CFDictionary, nil)
        }
    }

    #if DEBUG
    static func reset() {
        UserDefaults.standard.removeObject(forKey: defaultsKey)
        SecItemDelete([
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service
        ] as CFDictionary)
    }
    #endif
}
