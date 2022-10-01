// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "BackendApp",
    platforms: [.macOS(.v12)],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.0.0"),
        .package(url: "https://github.com/apple/swift-crypto.git", from: "1.0.0"),
        .package(url: "https://github.com/vapor/jwt-kit", from: "4.7.0")
    ],
    targets: [
        .target(name: "BackendApp", dependencies: [
            .product(name: "Fluent", package: "fluent"),
            .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
            .product(name: "Vapor", package: "vapor"),
            .product(name: "Crypto", package: "swift-crypto"),
            .product(name: "JWTKit", package: "jwt-kit")
        ]),
        .executableTarget(name: "Backend", dependencies: ["BackendApp"]),
        .testTarget(name: "BackendAppTests", dependencies: ["BackendApp"])
    ]
)
