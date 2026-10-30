// swift-tools-version: 5.9
  import PackageDescription

  let package = Package(
      name: "IntelinteractWidget",
      platforms: [.iOS(.v15)],
      products: [
          .library(name: "IntelinteractWidget", targets: ["IntelinteractWidget"])
      ],
      dependencies: [
          .package(url: "https://github.com/livekit/client-sdk-swift.git", exact: "2.18.0")
      ],
      targets: [
          .binaryTarget(
              name: "IntelinteractWidgetCore",
              url: "https://github.com/aamir-core/intelinteract-ios-sdk-releases/releases/download/1.1.0/IntelinteractWidgetCore.xcframework.zip",
              checksum: "c344047c46da9eb205078dc476aa16964261825722848ea58ea72bbd889759ff"
          ),
          .target(
              name: "IntelinteractWidget",
              dependencies: [
                  "IntelinteractWidgetCore",
                  .product(name: "LiveKit", package: "client-sdk-swift")
              ]
          )
      ]
  )
