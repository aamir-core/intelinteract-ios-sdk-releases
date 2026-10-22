 // swift-tools-version: 5.9
  import PackageDescription

  let package = Package(
      name: "IntelinteractWidget",
      platforms: [.iOS(.v15)],
      products: [
          .library(name: "IntelinteractWidget", targets: ["IntelinteractWidgetCore"])
      ],
      dependencies: [          
          .package(url: "https://github.com/livekit/client-sdk-swift.git", from: "2.5.0")
      ],
      targets: [
          .binaryTarget(
              name: "IntelinteractWidgetCore",
              url: "https://github.com/aamir-core/intelinteract-ios-sdk-releases/releases/download/1.0.0/IntelinteractWidgetCore.xcframework.zip",
              checksum: "ff541a164b228a79c978b1f3106e65d157e66c20518c01f9f01e55bf3ef33b51"
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
