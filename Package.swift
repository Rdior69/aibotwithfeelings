// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "aibotwithfeelings",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .visionOS(.v1),
    ],
    products: [
        .library(
            name: "AIBotCompanionCore",
            targets: ["AIBotCompanionCore"]
        ),
    ],
    targets: [
        .target(
            name: "AIBotCompanionCore",
            path: "aibotwithfeelings",
            exclude: [
                "Assets.xcassets",
                "ContentView.swift",
                "aibotwithfeelingsApp.swift",
                "Views",
                "ViewModels",
            ]
        ),
        .testTarget(
            name: "AIBotCompanionCoreTests",
            dependencies: ["AIBotCompanionCore"],
            path: "Tests/AIBotCompanionCoreTests"
        ),
    ]
)
