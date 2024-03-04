// swift-tools-version: 5.7.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "TyroApplePay",
  platforms: [.macOS(.v13), .iOS(.v16)],
  products: [
    .library(
      name: "TyroApplePay",
      targets: ["TyroApplePay"])
  ],
  dependencies: [
    .package(url: "https://github.com/Quick/Nimble.git", from: "13.2.0"),
    .package(url: "https://github.com/Quick/Quick.git", from: "7.4.0"),
    .package(url: "https://github.com/realm/SwiftLint.git", from: "0.54.0"),
    .package(url: "https://github.com/nicklockwood/SwiftFormat", from: "0.53.1"),
    .package(url: "https://github.com/SwiftyBeaver/SwiftyBeaver.git", .upToNextMajor(from: "2.0.0")),
    .package(url: "https://github.com/hmlongco/Factory.git", from: "2.3.1")
  ],
  targets: [
    .target(
      name: "TyroApplePay",
			dependencies: ["SwiftyBeaver", "Factory"],
			path: "Sources",
			exclude: ["TyroApplePay.xcworkspace", "README.md", "TyroApplePayTests"],
      plugins: [.plugin(name: "SwiftLintPlugin", package: "SwiftLint")]
    ),
    .testTarget(
      name: "TyroApplePayTests",
      dependencies: ["TyroApplePay", "Quick", "Nimble", "SwiftyBeaver"],
			path: "Tests"
    )
  ]
)
