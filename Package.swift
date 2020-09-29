// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "VaporAuth",
    platforms: [.macOS(.v10_15)],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0-rc"),
        .package(url: "https://github.com/vapor/fluent-sqlite-driver.git", from: "4.0.0"),
        .package(url: "https://github.com/apple/swift-crypto.git", from: "1.0.0"),
    ],
    targets: [
        .target(name: "App", dependencies: [
                    .product(name: "Fluent", package: "fluent"),
                    .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver"),
                    .product(name: "Vapor", package: "vapor"),
                    .product(name: "Crypto", package: "swift-crypto")
        ]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
        ]
)
