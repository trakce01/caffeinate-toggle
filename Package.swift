// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CaffeinateToggle",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "CaffeinateToggle",
            path: "Sources/CaffeinateToggle",
            resources: [.copy("Resources")]
        )
    ]
)
