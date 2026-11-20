import SwiftUI

struct Theme: Identifiable, Equatable {
    let id: String
    let name: String          // Marka adı gibi davranır, çevrilmez.
    let top: Color
    let bottom: Color
    let glow: Color           // Işık açıkken yayılan renk
    let core: Color           // Butonun merkezindeki en parlak ton
    let isPremium: Bool

    static let obsidian = Theme(id: "obsidian", name: "Obsidian",
                                top: Color(hex: 0x15161A), bottom: Color(hex: 0x050506),
                                glow: Color(hex: 0xFFE8B8), core: .white, isPremium: false)
    static let aurora = Theme(id: "aurora", name: "Aurora",
                              top: Color(hex: 0x101B2E), bottom: Color(hex: 0x05060F),
                              glow: Color(hex: 0x5EF2D6), core: Color(hex: 0xE9FFFB), isPremium: true)
    static let ember = Theme(id: "ember", name: "Ember",
                             top: Color(hex: 0x2A0F0C), bottom: Color(hex: 0x0B0405),
                             glow: Color(hex: 0xFF7A45), core: Color(hex: 0xFFF1E6), isPremium: true)
    static let glacier = Theme(id: "glacier", name: "Glacier",
                               top: Color(hex: 0x0E1A26), bottom: Color(hex: 0x03070C),
                               glow: Color(hex: 0x8CC8FF), core: Color(hex: 0xF2F9FF), isPremium: true)
    static let aurum = Theme(id: "aurum", name: "Aurum",
                             top: Color(hex: 0x1C1710), bottom: Color(hex: 0x070604),
                             glow: Color(hex: 0xE6C27A), core: Color(hex: 0xFFF8E7), isPremium: true)

    static let all: [Theme] = [.obsidian, .aurora, .ember, .glacier, .aurum]

    static func with(id: String) -> Theme { all.first { $0.id == id } ?? .obsidian }
}

extension Color {
    init(hex: UInt32) {
        self.init(.sRGB,
                  red: Double((hex >> 16) & 0xFF) / 255,
                  green: Double((hex >> 8) & 0xFF) / 255,
                  blue: Double(hex & 0xFF) / 255,
                  opacity: 1)
    }
}
