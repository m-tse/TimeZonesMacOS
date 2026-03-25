import SwiftUI

@main
struct WorldClockApp: App {
    @StateObject private var store = TimezoneStore()

    var body: some Scene {
        MenuBarExtra {
            ContentView()
                .environmentObject(store)
                .background(VisualEffectBackground())
        } label: {
            Image(systemName: "globe")
        }
        .menuBarExtraStyle(.window)
    }
}
