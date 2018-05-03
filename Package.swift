// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Vapor-Auth",
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0-rc"),
        .package(url: "https://github.com/vapor/fluent-sqlite.git", from: "3.0.0-rc.2.1"),
        .package(url: "https://github.com/vapor/auth.git", from: "2.0.0-rc"),
        .package(url: "https://github.com/vapor/crypto.git", from: "3.0.0")
    ],
    targets: [
        .target(name: "App", dependencies: ["Vapor", "FluentSQLite", "Authentication", "Crypto"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
        ]
)
