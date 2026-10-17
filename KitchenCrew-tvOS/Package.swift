// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "KitchenCrew",
    defaultLocalization: "en",
    platforms: [
        .tvOS(.v17),
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "KitchenCrewTV",
            targets: ["KitchenCrewTV"]
        ),
        .library(
            name: "KitchenCrewCompanion",
            targets: ["KitchenCrewCompanion"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "KitchenCrewTV",
            dependencies: [],
            path: "Sources/KitchenCrewTV",
            resources: []
        ),
        .target(
            name: "KitchenCrewCompanion",
            dependencies: ["KitchenCrewTV"],
            path: "Sources/KitchenCrewCompanion",
            resources: []
        ),
        .testTarget(
            name: "KitchenCrewTests",
            dependencies: ["KitchenCrewTV", "KitchenCrewCompanion"],
            path: "Tests/KitchenCrewTests"
        )
    ]
)
