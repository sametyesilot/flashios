import SwiftUI

@main
struct LumoraApp: App {
    @State private var torch = TorchController()
    @State private var store = StoreManager()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(torch)
                .environment(store)
                .preferredColorScheme(.dark)
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                torch.syncWithHardware()
                Task { await store.refreshEntitlements() }
            }
        }
    }
}
