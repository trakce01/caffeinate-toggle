import AppKit

enum MenuBarIcon {
    static func load(active: Bool) -> NSImage {
        let name = active ? "cup-on" : "cup-off"
        guard let url = Bundle.module.url(forResource: name, withExtension: "svg", subdirectory: "Resources"),
              let image = NSImage(contentsOf: url) else {
            return NSImage(systemSymbolName: "cup.and.saucer", accessibilityDescription: nil)!
        }
        image.size = NSSize(width: 18, height: 18)
        image.isTemplate = true
        return image
    }
}
