// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "IntelinteractWidget",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "IntelinteractWidget", targets: ["IntelinteractWidget"])
    ],
    dependencies: [
        .package(url: "https://github.com/livekit/client-sdk-swift.git", .upToNextMajor(from: "2.0.0"))
    ],
    targets: [
        .target(
            name: "IntelinteractWidget",
            dependencies: [
                .product(name: "LiveKit", package: "client-sdk-swift"),
                "IntelinteractWidgetCore"
            ],
            path: "Sources/IntelinteractWidgetStub"
        ),
        .binaryTarget(
            name: "IntelinteractWidgetCore",
            url: "https://github.com/aamir-core/intelinteract-ios-sdk-releases/releases/download/1.0.0/IntelinteractWidgetCore.xcframework.zip",
            checksum: "97d3871385f9d3f837c088ae392df9dc82bf0e7bca6f8a36878991ee52941279"
        )
    ]
)
