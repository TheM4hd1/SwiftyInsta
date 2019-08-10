// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "SwiftyInsta",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "SwiftyInsta",
            targets: ["SwiftyInsta.iOS"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/evgenyneu/keychain-swift.git", from: "16.0.0"),
        .package(url: "https://github.com/1024jp/GzipSwift.git", from: "5.0.0"),
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "SwiftyInsta.iOS",
            dependencies: ["KeychainSwift", "GzipSwift", "CryptoSwift"],
            path: "SwiftyInsta"
        ),
    ]
)
