import SwiftUI

@main
struct CaffeinateToggleApp: App {
    @StateObject private var manager = CaffeinateManager()

    var body: some Scene {
        MenuBarExtra {
            if manager.isActive {
                Text("On for \(manager.elapsed)")
                    .font(.subheadline)
            }

            Button(manager.isActive ? "Turn Off" : "Turn On") {
                manager.isActive.toggle()
            }
            .keyboardShortcut("t")

            Divider()

            Button("Quit") {
                manager.stop()
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        } label: {
            Image(nsImage: MenuBarIcon.load(active: manager.isActive))
        }
    }
}
