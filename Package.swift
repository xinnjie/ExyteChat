// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "Chat",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "ExyteChat",
            targets: ["ExyteChat"]),
    ],
    traits: [
        // MediaPicker is part of the default feature set. Clients can opt out by disabling default traits.
        .default(enabledTraits: ["MediaPicker"]),
        .trait(
            name: "MediaPicker",
            description: "Enable the built-in media picker integration."
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/exyte/MediaPicker.git",
            from: "3.3.2"
        ),
        .package(
            url: "https://github.com/exyte/ActivityIndicatorView",
            from: "1.0.0"
        ),
        .package(
           url: "https://github.com/Giphy/giphy-ios-sdk",
           exact: "2.2.16"
        ),
        .package(
            url: "https://github.com/onevcat/Kingfisher",
            from: "8.5.0"
        ),
    ],
    targets: [
        .target(
            name: "ExyteChat",
            dependencies: [
                .product(
                    name: "ExyteMediaPicker",
                    package: "MediaPicker",
                    // ExyteMediaPicker is currently iOS-only. We exclude it on macOS to prevent build errors
                    // even if the "MediaPicker" trait is enabled in the environment.
                    condition: .when(platforms: [.iOS], traits: ["MediaPicker"])
                ),
                .product(name: "ActivityIndicatorView", package: "ActivityIndicatorView"),
                // GiphyUISDK is currently iOS-only.
                .product(name: "GiphyUISDK", package: "giphy-ios-sdk", condition: .when(platforms: [.iOS])),
                .product(name: "Kingfisher", package: "Kingfisher")
            ],
            resources: [
                .process("Resources")
            ],
            swiftSettings: [
                // Source files use this flag to hide MediaPicker-only API and UI.
                .define("EXYTE_CHAT_ENABLE_MEDIA_PICKER", .when(platforms: [.iOS], traits: ["MediaPicker"])),
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "ExyteChatTests",
            dependencies: ["ExyteChat"]),
    ],
    swiftLanguageModes: [.v5]
)
