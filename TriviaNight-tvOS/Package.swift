// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TriviaNight",
    defaultLocalization: "en",
    platforms: [
        .tvOS(.v17),
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "TriviaNightTV",
            targets: ["TriviaNightTV"]
        ),
        .library(
            name: "TriviaNightCompanion",
            targets: ["TriviaNightCompanion"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "TriviaNightTV",
            dependencies: [],
            path: "Sources/TriviaNightTV",
            resources: []
        ),
        .target(
            name: "TriviaNightCompanion",
            dependencies: ["TriviaNightTV"],
            path: "Sources/TriviaNightCompanion",
            resources: []
        )
    ]
)
