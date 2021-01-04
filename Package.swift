// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "strava-client",
    products: [
        .library(name: "strava-client", targets: ["App"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", .exact("3.3.1")),
		.package(url: "https://github.com/vapor/fluent-postgresql.git", .exact("1.0.0")),
        .package(url: "https://github.com/vapor/core.git", .exact("3.9.2")),
        .package(url: "https://github.com/vapor/crypto.git", .exact("3.3.3")),
        .package(url: "https://github.com/vapor/http.git", .exact("3.2.1")),
        .package(url: "https://github.com/vapor/multipart.git", .exact("3.0.4")),
        .package(url: "https://github.com/vapor/postgresql.git", .exact("1.5.0")),
        .package(url: "https://github.com/apple/swift-nio.git", .exact("1.14.1")),
        .package(url: "https://github.com/vapor/template-kit.git", .exact("1.4.0")),
        .package(url: "https://github.com/vapor/url-encoded-form.git", .exact("1.0.6")),
    ],
    targets: [
        .target(name: "App", dependencies: ["Vapor", "FluentPostgreSQL"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

