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
        .library(
            name: "AIBotCompanionUI",
            targets: ["AIBotCompanionUI"]
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
        .target(
            name: "AIBotCompanionUI",
            dependencies: ["AIBotCompanionCore"],
            path: "aibotwithfeelings",
            exclude: [
                "Models",
                "Services",
                "aibotwithfeelingsApp.swift",
            ],
            sources: [
                "ViewModels",
                "Views",
                "ContentView.swift",
            ],
            resources: [
                .process("Assets.xcassets"),
            ]
        ),
        .testTarget(
            name: "AIBotCompanionCoreTests",
            dependencies: ["AIBotCompanionCore"],
            path: "Tests/AIBotCompanionCoreTests"
        ),
    ]
)
