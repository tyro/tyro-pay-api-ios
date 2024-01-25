// swift-tools-version: 5.7.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "TyroApplePay",
  platforms: [.macOS(.v11), .iOS(.v13)],
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(
      name: "TyroApplePay",
      targets: ["TyroApplePay"]),
  ],
  dependencies: [
    .package(url: "https://github.com/Quick/Nimble.git", from: "13.2.0"),
    .package(url: "https://github.com/Quick/Quick.git", from: "7.4.0")
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "TyroApplePay"),
    .testTarget(
      name: "TyroApplePayPackageTests",
      dependencies: ["TyroApplePay", "Quick", "Nimble"]),
  ]
  // swiftLanguageVersions: [.version("5.7.1")]
)
