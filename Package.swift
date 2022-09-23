// swift-tools-version: 5.7
import PackageDescription

let swiftSettings: [SwiftSetting] = [
  //.unsafeFlags(["-Xfrontend", "-warn-concurrency"], .when(configuration: .debug)),
  //.unsafeFlags(["-Xfrontend", "-debug-time-function-bodies"], .when(configuration: .debug)),
  //.unsafeFlags(["-Xfrontend", "-debug-time-expression-type-checking"], .when(configuration: .debug)),
]

let package = Package(
  name: "xx-client-ios-db",
  platforms: [
    .iOS(.v14),
    .macOS(.v12),
  ],
  products: [
    .library(name: "XXModels", targets: ["XXModels"]),
    .library(name: "XXLegacyDatabaseMigrator", targets: ["XXLegacyDatabaseMigrator"]),
    .library(name: "XXDatabase", targets: ["XXDatabase"]),
  ],
  dependencies: [
    .package(url: "https://github.com/groue/GRDB.swift", .upToNextMajor(from: "6.0.0")),
    .package(url: "https://github.com/pointfreeco/swift-custom-dump.git", .upToNextMajor(from: "0.5.2")),
    .package(url: "https://github.com/pointfreeco/swift-snapshot-testing.git", .upToNextMajor(from: "1.10.0")),
    .package(url: "https://github.com/pointfreeco/xctest-dynamic-overlay.git", .upToNextMajor(from: "0.4.1")),
  ],
  targets: [
    .target(
      name: "XXModels",
      dependencies: [
        .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
      ],
      swiftSettings: swiftSettings
    ),
    .testTarget(
      name: "XXModelsTests",
      dependencies: [
        .target(name: "XXModels"),
      ],
      swiftSettings: swiftSettings
    ),
    .target(
      name: "XXLegacyDatabaseMigrator",
      dependencies: [
        .target(name: "XXDatabase"),
        .target(name: "XXModels"),
        .product(name: "GRDB", package: "GRDB.swift"),
        .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
      ],
      swiftSettings: swiftSettings
    ),
    .testTarget(
      name: "XXLegacyDatabaseMigratorTests",
      dependencies: [
        .target(name: "XXLegacyDatabaseMigrator"),
        .product(name: "CustomDump", package: "swift-custom-dump"),
        .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
      ],
      exclude: [
        "__Snapshots__",
      ],
      resources: [
        .copy("Resources/legacy_database_1.sqlite"),
        .copy("Resources/legacy_database_1_meMarshaled_base64.txt"),
        .copy("Resources/legacy_database_2.sqlite"),
        .copy("Resources/legacy_database_2_meMarshaled_base64.txt"),
      ],
      swiftSettings: swiftSettings
    ),
    .target(
      name: "XXDatabase",
      dependencies: [
        .target(name: "XXModels"),
        .product(name: "GRDB", package: "GRDB.swift"),
      ],
      swiftSettings: swiftSettings
    ),
    .testTarget(
      name: "XXDatabaseTests",
      dependencies: [
        .target(name: "XXDatabase"),
        .product(name: "CustomDump", package: "swift-custom-dump"),
      ],
      swiftSettings: swiftSettings
    ),
  ]
)
