// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "MisakiSwift",
  platforms: [
    .iOS(.v18), .macOS(.v15)
  ],
  products: [
    .library(
      name: "MisakiSwift",
      type: .dynamic,
      targets: ["MisakiSwift"]
    ),
  ],
  dependencies: [
    // Keep these immutable Junco fork versions aligned with KokoroSwift.
    .package(url: "https://github.com/ahh1539/mlx-swift", exact: "0.31.6-junco.0.32.4"),
    .package(url: "https://github.com/ahh1539/MLXUtilsLibrary.git", exact: "0.0.6-junco.3")
  ],
  targets: [
    .target(
      name: "MisakiSwift",
      dependencies: [
        .product(name: "MLX", package: "mlx-swift"),
        .product(name: "MLXNN", package: "mlx-swift"),
        .product(name: "MLXUtilsLibrary", package: "MLXUtilsLibrary")
     ],
     resources: [
      .process("Resources")
     ]
    ),
    .testTarget(
      name: "MisakiSwiftTests",
      dependencies: ["MisakiSwift"]
    ),
  ]
)
